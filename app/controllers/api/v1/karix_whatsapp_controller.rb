# frozen_string_literal: true

class Api::V1::KarixWhatsappController < Api::ApiController
  before_action :authenticate_retailer_user!, except: :save_message

  include CurrentRetailer

  before_action :set_customer, only: [:messages, :send_file, :message_read, :set_chat_as_unread, :send_bulk_files,
    :create, :send_multiple_answers]
  before_action :validate_balance, only: [:create, :send_file, :send_bulk_files, :send_multiple_answers]
  protect_from_forgery only: [:save_message]

  def index
    customers = if current_retailer_user.admin? || current_retailer_user.supervisor?
                  current_retailer.customers.active_whatsapp
                elsif current_retailer_user.agent?
                  current_retailer_user.customers.active_whatsapp
                end

    @customers = customer_list(customers)

    # Se debe quitar primero el offset de Kaminari para que pueda tomar el del parametro
    @customers = @customers&.offset(false)&.offset(params[:offset])
    total_pages = @customers&.total_pages

    if @customers.present?
      render status: 200, json: {
        customers: @customers.as_json(
          methods: [
            :unread_whatsapp_message?,
            :recent_inbound_message_date,
            :assigned_agent,
            :last_whatsapp_message,
            :handle_message_events?,
            :unread_whatsapp_messages,
            :tags,
            :last_messages,
            :has_pending_reminders,
            :has_deals
          ]
        ),
        agents: agents,
        agent_list: current_retailer.team_agents,
        storage_id: current_retailer_user.storage_id,
        filter_tags: current_retailer.tags,
        total_customers: total_pages,
        gupshup_integrated: current_retailer.gupshup_integrated?,
        allow_send_voice: current_retailer.allow_voice_notes,
        balance_error_info: !current_retailer.positive_balance? ? balance_error : nil
      }
    else
      render status: 404, json: {
        message: 'Customers not found',
        agents: agents,
        agent_list: current_retailer.team_agents,
        storage_id: current_retailer_user.storage_id,
        filter_tags: current_retailer.tags,
        customers: [],
        gupshup_integrated: current_retailer.gupshup_integrated?,
        allow_send_voice: current_retailer.allow_voice_notes
      }
    end
  end

  # Improved endpoint for mobile apps
  def index_mobile
    customers = if current_retailer_user.admin? || current_retailer_user.supervisor?
                  current_retailer.customers.active_whatsapp
                elsif current_retailer_user.agent?
                  current_retailer_user.customers.active_whatsapp
                end
    @customers = customer_list(customers)
    # Se debe quitar primero el offset de Kaminari para que pueda tomar el del parametro
    @customers = @customers&.offset(false)&.offset(params[:offset])
    total_pages = @customers&.total_pages

    #TODO necesitamos mover el agents a su propio endpoint y borrarlo de aqui
    #TODO filter_tags mover a su propio endpoint y borrarlo de aqui.

    if @customers.present?
      render status: 200, json: {
        customers: @customers.as_json(
          methods: [
            :unread_whatsapp_message?,
            :recent_inbound_message_date,
            :assigned_agent_mobile,
            :handle_message_events?,
            :unread_whatsapp_messages,
            :tags,
            :has_pending_reminders,
            :has_deals
          ]
        ),
        agents: agents,
        storage_id: current_retailer_user.storage_id,
        filter_tags: current_retailer.tags,
        total_customers: total_pages,
        gupshup_integrated: current_retailer.gupshup_integrated?,
        allow_send_voice: current_retailer.allow_voice_notes,
        balance_error_info: !current_retailer.positive_balance? ? balance_error : nil
      }
    else
      render status: 404, json: {
        message: 'Customers not found',
        agents: agents,
        storage_id: current_retailer_user.storage_id,
        filter_tags: current_retailer.tags,
        customers: [],
        gupshup_integrated: current_retailer.gupshup_integrated?,
        allow_send_voice: current_retailer.allow_voice_notes
      }
    end
  end

  def create
    integration = current_retailer.karix_integrated? ? 'karix' : 'gupshup'
    self.send("send_#{integration}_notification", @customer, params, params[:type])
  end

  def messages
    @messages = customer_messages
    if @messages.present?
      agents_to_notify = @customer.agent.present? ? [@customer.agent] : current_retailer
        .retailer_users.all_customers.to_a

      total_pages = @messages.total_pages
      if current_retailer.karix_integrated?
        KarixNotificationHelper.broadcast_data(current_retailer, agents_to_notify, nil,
          @messages.first.customer.agent_customer, @customer)
        @messages = serialize_karix_messages.to_a.reverse
      elsif current_retailer.gupshup_integrated?
        @messages = Whatsapp::Gupshup::V1::Helpers::Messages.new(@messages).notify_messages!(
          current_retailer,
          agents_to_notify
        ).reverse
      end

      resp = {
        messages: @messages,
        agents: agents,
        agent_list: current_retailer.team_agents,
        storage_id: current_retailer_user.storage_id,
        handle_message_events: @customer.handle_message_events?,
        total_pages: total_pages,
        filter_tags: current_retailer.tags,
        gupshup_integrated: current_retailer.gupshup_integrated?,
        allow_send_voice: current_retailer.allow_voice_notes
      }

      if current_retailer.positive_balance?(@customer)
        resp[:recent_inbound_message_date] = @customer.recent_inbound_message_date
        resp[:customer_id] = @customer.id
      else
        resp[:balance_error_info] = balance_error
      end

      render status: 200, json: resp
    else
      render status: 404, json: {
        message: 'Messages not found',
        gupshup_integrated: current_retailer.gupshup_integrated?,
        allow_send_voice: current_retailer.allow_voice_notes
      }
    end
  end

  def save_message
    if params['error'].present?
      render json: { message: params['error']['message'] }, status: 500
      return
    end
    retailer = Retailer.find_by_id(params['account_id'])
    if retailer
      message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: params['data']['uid'])
      karix_helper = KarixNotificationHelper
      message = karix_helper.ws_message_service.assign_message(message, retailer, params['data'])
      message.save

      agents = message.customer.agent.present? ? [message.customer.agent] : retailer.retailer_users
        .all_customers.to_a
      karix_helper.broadcast_data(retailer, agents, message, message.customer.agent_customer) if message.persisted?
      render status: 200, json: { message: 'Succesful' }
    else
      render status: 404, json: { message: 'Account not found' }
    end
  end

  def send_file
    if current_retailer.karix_integrated?
      karix_helper = KarixNotificationHelper

      response = karix_helper.ws_message_service.send_message(current_retailer, @customer, params, 'file')

      if response['error'].present?
        render status: 500, json: {
          message: response['error']['message'],
          recent_inbound_message_date: @customer.recent_inbound_message_date
        }
      else
        has_agent = @customer.agent_customer.present?
        # Asignamos(solo la primera interaccion) el agente/admin al customer
        AgentCustomer.create_with(retailer_user: current_retailer_user)
                     .find_or_create_by(customer: @customer)

        message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
        message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0],
                                                                 current_retailer_user, params[:message_identifier])
        message.save

        unless has_agent
          karix_helper.broadcast_data(current_retailer, current_retailer.retailer_users.all_customers.to_a, nil,
            @customer.agent_customer)
        end

        render status: 200, json: {
          message: response['objects'][0],
          recent_inbound_message_date: @customer.recent_inbound_message_date
        }
      end
    elsif current_retailer.gupshup_integrated?
      assign_agent(@customer)
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, @customer)
      gws.send_message(type: 'file', params: params, retailer_user: current_retailer_user)
      render status: 200, json: {
        message: 'Notificaci??n enviada',
        recent_inbound_message_date: @customer.recent_inbound_message_date
      }
    end
  end

  def message_read
    @message = @customer.whatsapp_messages.find(params[:message_id])

    if @message.update_column(:status, 'read')
      @message.customer.update_attribute(:unread_whatsapp_chat, false)
      retailer_user_api(@customer, current_retailer).mark_unread_flag
      agents = @message.customer.agent.present? ? [@message.customer.agent] : current_retailer
        .retailer_users.all_customers.to_a

      if current_retailer.karix_integrated?
        KarixNotificationHelper.broadcast_data(current_retailer, agents, nil, @message.customer.agent_customer,
          @message.customer)
      elsif current_retailer.gupshup_integrated?
        @message = Whatsapp::Gupshup::V1::Helpers::Messages.new(@message).notify_read!(
          current_retailer,
          agents
        )
      end
      render status: 200, json: {
        message: @message,
        recent_inbound_message_date: @customer.recent_inbound_message_date,
      }
    else
      render status: 500, json: { message: 'Error al actualizar mensajes' }
    end
  end

  # Filtra las plantillas para whatsapp por titulo o respuesta
  def fast_answers_for_whatsapp
    templates = current_retailer.templates.for_whatsapp.owned_and_filtered(params[:search], current_retailer_user.id)
      .page(params[:page])

    serialized = Api::V1::TemplateSerializer.new(templates)
    render status: 200, json: { templates: serialized, total_pages: templates.total_pages }
  end

  def set_chat_as_unread
    # Si el chat no est?? signado, se le notifican a todos
    agents = current_retailer.retailer_users.all_customers.to_a

    # Si el chat est?? asignado se le notifica a los admnnistradores
    # y al agente asignado
    if @customer.agent.present?
      admins = current_retailer.retailer_users.where(retailer_admin: true).to_a
      supervisors = current_retailer.retailer_users.where(retailer_supervisor: true).to_a
      agents = [@customer.agent] | admins | supervisors
    end

    case params.try(:[], :chat_service)
    when 'facebook', 'instagram'
      # Se setea el chat como unread
      @customer.update_attribute(:unread_messenger_chat, true)
      facebook_helper = FacebookNotificationHelper
      facebook_helper.broadcast_data(
        current_retailer,
        agents,
        nil,
        @customer.agent_customer,
        @customer,
        params[:chat_service]
      )
    when 'whatsapp'
      # Se setea el chat como unread
      @customer.update_attribute(:unread_whatsapp_chat, true)
      if current_retailer.karix_integrated?
        karix_helper = KarixNotificationHelper
        karix_helper.broadcast_data(
          current_retailer,
          agents,
          nil,
          @customer.agent_customer,
          @customer
        )
      else
        message_helper = Whatsapp::Gupshup::V1::Helpers::Messages.new()
        agents.each do |ru|
          message_helper.notify_new_counter(ru, @customer)
        end
      end
    end

    render status: 200, json: { message: 'Successful' }
  end

  def send_bulk_files
    assign_agent(@customer)
    if current_retailer.karix_integrated?
      karix_helper = KarixNotificationHelper
      karix_helper.ws_message_service.send_bulk_files(retailer: current_retailer, retailer_user: current_retailer_user,
                                                      customer: @customer, params: params, type: 'file')
    elsif current_retailer.gupshup_integrated?
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, @customer)
      gws.send_bulk_files(type: 'file', params: params, retailer_user: current_retailer_user)
    end

    render status: 200, json: {
      message: 'Notificaci??n enviada',
      recent_inbound_message_date: @customer.recent_inbound_message_date
    }
  rescue => e
    Rails.logger.error(e)
    SlackError.send_error(e)
    render status: 400, json: {message: "Faltaron par??metros"}
  end

  def send_multiple_answers
    assign_agent(@customer)

    if current_retailer.karix_integrated?
      karix_helper = KarixNotificationHelper
      karix_helper.ws_message_service.send_multiple_answers(retailer: current_retailer,
        retailer_user: current_retailer_user, customer: @customer, params: params)
    elsif current_retailer.gupshup_integrated?
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, @customer)
      gws.send_multiple_answers(params: params, retailer_user: current_retailer_user)
    end

    render status: 200, json: {
      message: 'Notificaci??n enviada',
      recent_inbound_message_date: @customer.recent_inbound_message_date
    }
  rescue => e
    Rails.logger.error(e)
    SlackError.send_error(e)
    render status: 400, json: {message: "Faltaron par??metros"}
  end

  private

    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def balance_error
      {
        status: 401,
        message: 'Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, por favor recargue'
      }
    end

    def validate_balance
      if current_retailer.karix_integrated?
        is_template = ActiveModel::Type::Boolean.new.cast(params[:template])

        return if current_retailer.unlimited_account && is_template == false
      end

      return if params[:note] == true || current_retailer.positive_balance?(@customer)

      render status: 401, json: balance_error
    end

    def customer_list(customers)
      return nil unless customers.present?

      customers = customers.select('customers.*, customers.last_chat_interaction as recent_message_date')

      customers = case params[:type]
                  when 'no_read'
                    customers.where('unread_whatsapp_chat = true OR count_unread_messages > 0')
                  when 'read'
                    customers.where('unread_whatsapp_chat = false AND count_unread_messages = 0')
                  when 'all'
                    customers
                  end

      customers = case params[:agent]
                  when 'all'
                    customers
                  when 'not_assigned'
                    customers.joins('LEFT JOIN agent_customers agc ON agc.customer_id = customers.id')
                      .where('agc.retailer_user_id is NULL AND customers.retailer_id = ?', current_retailer.id)
                  else
                    customer_ids = AgentCustomer.where(retailer_user_id: params[:agent]).select(:customer_id)
                    customers.where('customers.id IN (?)', customer_ids)
                  end

      customers = case params[:tag]
                  when 'all'
                    customers
                  else
                    customer_ids = CustomerTag.where(tag_id: params[:tag]).select(:customer_id)
                    customers.where('customers.id IN (?)', customer_ids)
                  end

      customers = case params[:status]
                  when 'all', nil
                    customers
                  else
                    customers.where(status_chat: params[:status])
                  end

      # Es necesario para no causar problemas en la app mobile
      if params[:status] == 'all' && params[:tab].present?
        customers = case params[:tab]
                    when 'all'
                      customers
                    when 'pending'
                      customers.where(status_chat: ['new_chat', 'open_chat', 'in_process'])
                    when 'resolved'
                      customers.where(status_chat: params[:tab])
                    end
      end

      customers = customers.by_search_text(params[:searchString]) if params[:searchString]
      customers = customers.where('customers.id = ?', params[:customer_id]) if params[:customer_id].present?
      order = 'recent_message_date desc'
      if params[:order].present?
        case params[:order]
        when 'received_asc'
          order = 'recent_message_date asc'
        end
      end

      if current_retailer_user.only_assigned? && !(current_retailer_user.retailer_supervisor || current_retailer_user.retailer_admin)
        customer_ids = current_retailer_user.a_customers.select(:id)
        customers = customers.where(id: customer_ids)
      end
      customers = customers.group('customers.id')
                           .order(order)
                           .page(params[:page])

      customers
    end

    def send_karix_notification(customer, params, type)
      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(current_retailer, customer, params, type)

      if response['error'].present?
        render status: 500, json: { message: response['error']['message'] }
      else
        has_agent = customer.agent_customer.present?
        assign_agent(customer)

        message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
        message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0],
                                                                 current_retailer_user, params[:message_identifier])
        message.save

        agents = customer.agent.present? && has_agent ? [customer.agent] : current_retailer.retailer_users
          .all_customers.to_a
        karix_helper.broadcast_data(current_retailer, agents, message, customer.agent_customer)
        render status: 200, json: {
          message: response['objects'][0],
          recent_inbound_message_date: customer.recent_inbound_message_date
        }
      end
    end

    def send_gupshup_notification(customer, params, type)
      agent_customer = assign_agent(customer)

      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, agent_customer.customer)
      type = 'template' if true?(params[:template])

      if params[:note] == true
        gws.create_note(params: params, retailer_user: current_retailer_user)
      else
        gws.send_message(type: type, params: params, retailer_user: current_retailer_user)
      end

      message_helper = Whatsapp::Gupshup::V1::Helpers::Messages.new

      agents = current_retailer.retailer_users.all_customers.to_a
      message_helper.notify_agent!(current_retailer, agents, agent_customer, customer)

      render status: 200, json: {
        message: 'Notificaci??n enviada',
        recent_inbound_message_date: customer.recent_inbound_message_date
      }
    end

    def assign_agent(customer)
      # Asignamos(solo la primera interacci??n) el agente/admin al customer
      AgentCustomer.create_with(retailer_user: current_retailer_user)
                   .find_or_create_by(customer: customer)
    end

    def customer_messages
      @customer.update_attribute(:unread_whatsapp_chat, false)
      if current_retailer.karix_integrated?
        @customer.karix_whatsapp_messages.where(direction: 'inbound').where.not(status: ['read', 'failed'])
          .update_all(status: 'read')

        # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
        messages = @customer.karix_whatsapp_messages.where.not(status: 'failed')

        messages = messages.order(created_time: :desc).page(params[:page])
        return messages
      elsif current_retailer.gupshup_integrated?
        @customer.gupshup_whatsapp_messages.where(direction: 'inbound').where.not(status: ['read', 'error'])
          .update_all(status: 'read')

        # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
        messages = @customer.gupshup_whatsapp_messages.allowed_messages

        messages = messages.order(created_at: :desc).page(params[:page])
        return messages
      end
      nil
    end

    def serialize_karix_messages
      ActiveModelSerializers::SerializableResource.new(
        @messages,
        each_serializer: KarixWhatsappMessageSerializer
      ).as_json
    end

    def true?(text)
      return true if text === 'true' || text === true
      false
    end

    def agents
      current_retailer_user.admin? ||
      current_retailer_user.supervisor? ?
        current_retailer.team_agents :
        [current_retailer_user]
    end

    def retailer_user_api(customer, retailer)
      @retailer_user_api = RetailerUsers::ManageUnreadMessages.new(customer, retailer)
    end
end
