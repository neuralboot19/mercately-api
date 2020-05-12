class Api::V1::KarixWhatsappController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!, except: :save_message
  before_action :validate_balance, only: [:create, :send_file]
  before_action :set_customer, only: [:messages, :send_file, :message_read]
  protect_from_forgery only: [:save_message]

  def index
    customers = if current_retailer_user.admin?
                  current_retailer.customers
                elsif current_retailer_user.agent?
                  filtered_customers = current_retailer_user.customers
                  Customer.where(id: filtered_customers.pluck(:id))
                end

    @customers = customer_list(customers)

    @customers = @customers.by_search_text(params[:customerSearch]) if params[:customerSearch]

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
            :handle_message_events?
          ]
        ),
        total_customers: total_pages
      }
    else
      render status: 404, json: {
        message: 'Customers not found',
        customers: []
      }
    end
  end

  def create
    customer = current_retailer.customers.find(params[:customer_id])

    if current_retailer.karix_integrated?
      return send_karix_notification(customer, params, 'text')
    elsif current_retailer.gupshup_integrated?
      return send_gupshup_notification(customer, params, 'text')
    end
  end

  def messages
    @messages = customer_messages

    if @messages.present?
      agents = @messages.first.customer.agent.present? ? [@messages.first.customer.agent] : current_retailer
        .retailer_users.to_a

      total_pages = @messages.total_pages
      if current_retailer.karix_integrated?
        KarixNotificationHelper.broadcast_data(current_retailer, agents)
        @messages = @messages.to_a.reverse
      elsif current_retailer.gupshup_integrated?
        @messages = Whatsapp::Gupshup::V1::Helpers::Messages.new(@messages).notify_messages!(
          current_retailer,
          agents,
          @customer
        ).reverse
      end

      if current_retailer.positive_balance?
        render status: 200, json: {
          messages: @messages,
          agents: current_retailer.team_agents,
          handle_message_events: @customer.handle_message_events?,
          total_pages: total_pages
        }
      else
        render status: 401, json: {
          messages: @messages,
          agents: current_retailer.team_agents,
          total_pages: total_pages,
          balance_error_info: balance_error
        }
      end
    else
      render status: 404, json: { message: 'Messages not found' }
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
        render status: 500, json: { message: response['error']['message'] }
      else
        karix_helper = KarixNotificationHelper
        has_agent = @customer.agent_customer.present?
        # Asignamos(solo la primera interaccion) el agente/admin al customer
        AgentCustomer.create_with(retailer_user: current_retailer_user)
                     .find_or_create_by(customer: @customer)

        message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
        message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0])
        message.save

        unless has_agent
          karix_helper.broadcast_data(current_retailer, current_retailer.retailer_users.to_a, nil,
            @customer.agent_customer)
        end

        render status: 200, json: { message: response['objects'][0] }
      end
    elsif current_retailer.gupshup_integrated?
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, @customer)
      gws.send_message(type: 'file', params: params)

      render status: 200, json: { message: 'Notificación enviada' }
    end
  end

  def message_read
    @message = @customer.whatsapp_messages.find(params[:message_id])

    if @message.update_column(:status, 'read')
      agents = @message.customer.agent.present? ? [@message.customer.agent] : current_retailer.retailer_users.to_a
      if current_retailer.karix_integrated?
        KarixNotificationHelper.broadcast_data(current_retailer, agents)
      elsif current_retailer.gupshup_integrated?
        @message = Whatsapp::Gupshup::V1::Helpers::Messages.new(@message).notify_read!(
          current_retailer,
          agents
        )
      end
      render status: 200, json: { message: @message }
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

      customers = customers.group('customers.id')
                           .order('recent_message_date desc')
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
        message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0])
        message.save

        agents = customer.agent.present? && has_agent ? [customer.agent] : current_retailer.retailer_users.to_a
        karix_helper.broadcast_data(current_retailer, agents, message, customer.agent_customer)
        render status: 200, json: { message: response['objects'][0] }
      end
    end

    def send_gupshup_notification(customer, params, type)
      agent_customer = assign_agent(customer)

      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, agent_customer.customer)
      gws.send_message(type: 'text', text: params[:message])

      message_helper = Whatsapp::Gupshup::V1::Helpers::Messages.new(gws)

      agents = current_retailer.retailer_users.to_a
      message_helper.notify_agent!(current_retailer, agents, agent_customer)

      render status: 200, json: { message: 'Notificación enviada' }
    end

    def assign_agent(customer)
      # Asignamos(solo la primera interacción) el agente/admin al customer
      AgentCustomer.create_with(retailer_user: current_retailer_user)
                   .find_or_create_by(customer: customer)
    end

    def customer_messages
      if current_retailer.karix_integrated?
        # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
        messages = @customer.karix_whatsapp_messages
        # Aca se colocan en status read los mensajes inbound que no se hayan leido hasta el momento
        # pertenecientes al customer en cuestion
        messages.where(direction: 'inbound').where.not(status: 'read').update_all(status: 'read')
        messages = messages.order(created_time: :desc).page(params[:page])
        return messages
      elsif current_retailer.gupshup_integrated?
        # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
        messages = @customer.gupshup_whatsapp_messages
        # Aca se colocan en status read los mensajes inbound que no se hayan leido hasta el momento
        # pertenecientes al customer en cuestion
        messages.where(direction: 'inbound').where.not(status: :read).update_all(status: :read)
        messages = messages.order(created_at: :desc).page(params[:page])
        return messages
      end
      nil
    end
end
