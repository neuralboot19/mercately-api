class Api::V1::KarixWhatsappController < Api::ApiController
  before_action :authenticate_retailer_user!, except: :save_message

  include CurrentRetailer

  before_action :validate_balance, only: [:create, :send_file, :send_bulk_files]
  before_action :set_customer, only: [:messages, :send_file, :message_read, :set_chat_as_unread, :send_bulk_files]
  protect_from_forgery only: [:save_message]

  def index
    customers = if current_retailer_user.admin? || current_retailer_user.supervisor?
                  current_retailer.customers
                elsif current_retailer_user.agent?
                  filtered_customers = current_retailer_user.customers
                  Customer.where(id: filtered_customers.pluck(:id))
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
            :tags
          ]
        ),
        agents: agents,
        agent_list: current_retailer.team_agents,
        storage_id: current_retailer_user.storage_id,
        filter_tags: current_retailer.tags,
        total_customers: total_pages,
        gupshup_integrated: current_retailer.gupshup_integrated?
      }
    else
      render status: 404, json: {
        message: 'Customers not found',
        agents: agents,
        agent_list: current_retailer.team_agents,
        storage_id: current_retailer_user.storage_id,
        filter_tags: current_retailer.tags,
        customers: [],
        gupshup_integrated: current_retailer.gupshup_integrated?
      }
    end
  end

  def create
    customer = current_retailer.customers.find(params[:customer_id])
    integration = current_retailer.karix_integrated? ? 'karix' : 'gupshup'
    return self.send("send_#{integration}_notification", customer, params, params[:type])
  end

  def messages
    @messages = customer_messages
    if @messages.present?
      agents = @messages.first.customer.agent.present? ? [@messages.first.customer.agent] : current_retailer
        .retailer_users.to_a

      total_pages = @messages.total_pages
      if current_retailer.karix_integrated?
        KarixNotificationHelper.broadcast_data(current_retailer, agents, nil, nil, @customer)
        @messages = serialize_karix_messages.to_a.reverse
      elsif current_retailer.gupshup_integrated?
        @messages = Whatsapp::Gupshup::V1::Helpers::Messages.new(@messages).notify_messages!(
          current_retailer,
          agents
        ).reverse
      end

      if current_retailer.unlimited_account || current_retailer.positive_balance?
        render status: 200, json: {
          messages: @messages,
          agents: agents,
          agent_list: current_retailer.team_agents,
          storage_id: current_retailer_user.storage_id,
          handle_message_events: @customer.handle_message_events?,
          total_pages: total_pages,
          recent_inbound_message_date: @customer.recent_inbound_message_date,
          customer_id: @customer.id,
          filter_tags: current_retailer.tags,
          gupshup_integrated: current_retailer.gupshup_integrated?
        }
      else
        render status: 401, json: {
          messages: @messages,
          agents: agents,
          agent_list: current_retailer.team_agents,
          storage_id: current_retailer_user.storage_id,
          handle_message_events: @customer.handle_message_events?,
          total_pages: total_pages,
          balance_error_info: balance_error,
          filter_tags: current_retailer.tags,
          gupshup_integrated: current_retailer.gupshup_integrated?
        }
      end
    else
      render status: 404, json: {
        message: 'Messages not found',
        gupshup_integrated: current_retailer.gupshup_integrated?
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

      agents = message.customer.agent.present? ? [message.customer.agent] : retailer.retailer_users.to_a
      karix_helper.broadcast_data(retailer, agents, message) if message.persisted?
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
                                                                 current_retailer_user)
        message.save

        unless has_agent
          karix_helper.broadcast_data(current_retailer, current_retailer.retailer_users.to_a, nil,
            @customer.agent_customer)
        end

        render status: 200, json: {
          message: response['objects'][0],
          recent_inbound_message_date: @customer.recent_inbound_message_date
        }
      end
    elsif current_retailer.gupshup_integrated?
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, @customer)
      gws.send_message(type: 'file', params: params, retailer_user: current_retailer_user)

      render status: 200, json: {
        message: 'Notificación enviada',
        recent_inbound_message_date: @customer.recent_inbound_message_date
      }
    end
  end

  def message_read
    @message = @customer.whatsapp_messages.find(params[:message_id])

    if @message.update_column(:status, 'read')
      @message.customer.update_attribute(:unread_whatsapp_chat, false)
      agents = @message.customer.agent.present? ? [@message.customer.agent] : current_retailer.retailer_users.to_a
      if current_retailer.karix_integrated?
        KarixNotificationHelper.broadcast_data(current_retailer, agents)
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
    templates = current_retailer.templates.for_whatsapp.where('title ILIKE ?' \
      ' OR answer ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%").page(params[:page])

    serialized = Api::V1::TemplateSerializer.new(templates)
    render status: 200, json: { templates: serialized, total_pages: templates.total_pages }
  end

  def set_chat_as_unread
    # Si el chat no está signado, se le notifican a todos
    agents = current_retailer.retailer_users.to_a

    # Si el chat está asignado se le notifica a los admnnistradores
    # y al agente asignado
    if @customer.agent.present?
      admins = current_retailer.retailer_users.where(retailer_admin: true).to_a
      supervisors = current_retailer.retailer_users.where(retailer_supervisor: true).to_a
      agents = [@customer.agent] | admins | supervisors
    end

    case params.try(:[],:chat_service)
    when 'facebook'
      # Se setea el chat como unread
      @customer.update_attribute(:unread_messenger_chat, true)
      facebook_helper = FacebookNotificationHelper
      facebook_helper.broadcast_data(
        current_retailer,
        agents,
        nil,
        @customer.agent_customer,
        @customer
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
          nil,
          @customer
        )
      else
        message_helper = Whatsapp::Gupshup::V1::Helpers::Messages.new()
        agents.each do |ru|
          message_helper.notify_new_counter(ru, @customer)
        end
      end
    end

    render status: 200,
           json: {
            customers: [
              @customer.as_json(
                methods: [
                  :unread_whatsapp_message?,
                  :unread_message?,
                  :recent_inbound_message_date,
                  :assigned_agent,
                  :last_whatsapp_message,
                  :handle_message_events?,
                  :unread_whatsapp_messages
                ]
              )
            ]
          }
  end

  def send_bulk_files
    if current_retailer.karix_integrated?
      karix_helper = KarixNotificationHelper
      karix_helper.ws_message_service.send_bulk_files(retailer: current_retailer, retailer_user: current_retailer_user,
                                                      customer: @customer, params: params, type: 'file')
    elsif current_retailer.gupshup_integrated?
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, @customer)
      gws.send_bulk_files(type: 'file', params: params, retailer_user: current_retailer_user)
    end

    render status: 200, json: {
      message: 'Notificación enviada',
      recent_inbound_message_date: @customer.recent_inbound_message_date
    }
  end

  private

    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def balance_error
      {
        status: 401,
        message: 'Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, ' \
                 'por favor, contáctese con su agente de ventas para recargar su saldo'
      }
    end

    def validate_balance
      is_template = ActiveModel::Type::Boolean.new.cast(params[:template])

      return if current_retailer.unlimited_account && is_template == false
      return if current_retailer.positive_balance?

      render status: 401, json: balance_error
    end

    def customer_list(customers)
      return nil unless customers.present?

      if current_retailer.karix_integrated?
        customers = customers.select("customers.*, max(karix_whatsapp_messages.created_time) as recent_message_date")
                 .joins(:karix_whatsapp_messages)
                 .where.not(karix_whatsapp_messages: { account_uid: nil })
      elsif current_retailer.gupshup_integrated?
        customers = customers.select("customers.*, max(gupshup_whatsapp_messages.created_at) as recent_message_date")
                 .joins(:gupshup_whatsapp_messages)
                 .where.not(gupshup_whatsapp_messages: { gupshup_message_id: nil })
      end

      integration = current_retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'
      if params[:type].present?
        customers = case params[:type]
                    when 'no_read'
                      customers.where("(#{integration}.status != ? AND #{integration}.direction = 'inbound')
                                       OR customers.unread_whatsapp_chat = true", current_retailer.karix_integrated? ? 'read' : 5)
                    when 'read'
                      customers.where(
                        "(#{integration}.status = ? AND #{integration}.direction = 'inbound')
                        AND customers.unread_whatsapp_chat = false",
                        current_retailer.karix_integrated? ? 'read' : 5
                      )
                    when 'all'
                      customers
                    end
      end

      if params[:agent].present?
        case params[:agent]
        when 'all'
          customers
        when 'not_assigned'
          customer_ids = AgentCustomer.all.pluck(:customer_id)
          customers = customers.where('customers.id NOT IN (?)', customer_ids)
        else
          customer_ids = AgentCustomer.where(retailer_user_id: params[:agent]).pluck(:customer_id)
          customers = customers.where('customers.id IN (?)', customer_ids)
        end
      end

      if params[:tag].present?
        case params[:tag]
        when 'all'
          customers
        else
          customer_ids = CustomerTag.where(tag_id: params[:tag]).pluck(:customer_id)
          customers = customers.where('customers.id IN (?)', customer_ids)
        end
      end

      customers = customers.by_search_text(params[:searchString]) if params[:searchString]
      order = 'recent_message_date desc'
      if params[:order].present?
        case params[:order]
        when 'received_asc'
          order = 'recent_message_date asc'
        end
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
                                                                 current_retailer_user)
        message.save

        agents = customer.agent.present? && has_agent ? [customer.agent] : current_retailer.retailer_users.to_a
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

      gws.send_message(type: type, params: params, retailer_user: current_retailer_user)

      message_helper = Whatsapp::Gupshup::V1::Helpers::Messages.new(gws)

      agents = current_retailer.retailer_users.to_a
      message_helper.notify_agent!(current_retailer, agents, agent_customer)

      render status: 200, json: {
        message: 'Notificación enviada',
        recent_inbound_message_date: customer.recent_inbound_message_date
      }
    end

    def assign_agent(customer)
      # Asignamos(solo la primera interacción) el agente/admin al customer
      AgentCustomer.create_with(retailer_user: current_retailer_user)
                   .find_or_create_by(customer: customer)
    end

    def customer_messages
      @customer.update_attribute(:unread_whatsapp_chat, false)
      if current_retailer.karix_integrated?
        # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
        messages = @customer.karix_whatsapp_messages
        # Aca se colocan en status read los mensajes inbound que no se hayan leido hasta el momento
        # pertenecientes al customer en cuestion
        messages.where(direction: 'inbound')
                .where.not(status: 'read')

        # for some reason if this filter is attached to the previous
        # query is not working
        messages = messages.where.not(status: 'failed')

        messages.update_all(status: 'read')
        messages = messages.order(created_time: :desc).page(params[:page])
        return messages
      elsif current_retailer.gupshup_integrated?
        # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
        messages = @customer.gupshup_whatsapp_messages
        # Aca se colocan en status read los mensajes inbound que no se hayan leido hasta el momento
        # pertenecientes al customer en cuestion
        messages.where(direction: 'inbound')
                .where.not(status: 'read')

        # for some reason if this filter is attached to the previous
        # query is not working
        messages = messages.where.not(status: 'error')

        messages.update_all(status: 'read')
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
end
