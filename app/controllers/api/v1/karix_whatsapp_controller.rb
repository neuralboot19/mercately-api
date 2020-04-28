class Api::V1::KarixWhatsappController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!, except: :save_message
  before_action :validate_balance, only: [:create, :send_file]
  before_action :set_customer, only: [:messages, :send_file, :message_read]
  protect_from_forgery :only => [:save_message]

  def index
    @customers = current_retailer.customers
      .select('customers.*, max(karix_whatsapp_messages.created_time) as recent_message_date')
      .joins(:karix_whatsapp_messages)
      .where.not(karix_whatsapp_messages: { account_uid: nil })
      .group('customers.id').order('recent_message_date desc').page(params[:page])

    if current_retailer_user.agent?
      # Despues de obtener la lista de ids de los clientes que tienen chats
      agent_customers = AgentCustomer.preload(:customer)

      # Se consiguen los customers con agente asignado diferente al agente logueado(current_retailer_user)
      customers_not_current = agent_customers.where.not(retailer_user: current_retailer_user)
                                             .map { |ac| ac.customer }

      # Son eliminados aquellos clientes a los que ya han sido asignados a otros retailers
      # de la lista de customers con chats de whatsapp
      filtered_customers = @customers.map { |c| c } - customers_not_current

      # Se prepara la lista de clientes final
      @customers = Customer.where(id: (filtered_customers).pluck(:id)).page(params[:page])
    end

    @customers = @customers.by_search_text(params[:customerSearch]) if params[:customerSearch]

    if @customers.present?
      render status: 200, json: {
        customers: @customers.as_json(
          methods: [
            :karix_unread_message?,
            :recent_inbound_message_date,
            :assigned_agent,
            :last_whatsapp_message
          ]
        ),
        total_customers: @customers.total_pages
      }
    else
      render status: 404, json: { message: 'Customers not found' }
    end
  end

  def create
    customer = current_retailer.customers.find(params[:customer_id])
    karix_helper = KarixNotificationHelper
    response = karix_helper.ws_message_service.send_message(current_retailer, customer, params, 'text')

    if response['error'].present?
      render status: 500, json: { message: response['error']['message'] }
    else
      has_agent = customer.agent_customer.present?
      # Asignamos(solo la primera interaccion) el agente/admin al customer
      AgentCustomer.create_with(retailer_user: current_retailer_user)
                   .find_or_create_by(customer: customer)

      message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0])
      message.save

      agents = customer.agent.present? && has_agent ? [customer.agent] : current_retailer.retailer_users.to_a
      karix_helper.broadcast_data(current_retailer, agents, message, customer.agent_customer)
      render status: 200, json: { message: response['objects'][0] }
    end
  end

  def messages
    # Aca se buscan todos los mensajes asociados al customer, tanto inbound como outbound
    @messages = @customer.karix_whatsapp_messages
    # Aca se colocan en status read los mensajes inbound que no se hayan leido hasta el momento
    # pertenecientes al customer en cuestion
    @messages.where(direction: 'inbound').where.not(status: 'read').update_all(status: 'read')
    @messages = @messages.order(created_time: :desc).page(params[:page])

    if @messages.present?
      agents = @messages.first.customer.agent.present? ? [@messages.first.customer.agent] : current_retailer
        .retailer_users.to_a
      KarixNotificationHelper.broadcast_data(current_retailer, agents)

      if current_retailer.positive_balance?
        render status: 200, json: { messages: @messages.to_a.reverse, agents:
          current_retailer.team_agents, total_pages: @messages.total_pages }
      else
        render status: 401, json: { messages: @messages.to_a.reverse, agents:
          current_retailer.team_agents, total_pages: @messages.total_pages, balance_error_info: balance_error }
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
  end

  def message_read
    @message = @customer.karix_whatsapp_messages.find(params[:message_id])

    if @message.update_column(:status, 'read')
      agents = @message.customer.agent.present? ? [@message.customer.agent] : current_retailer.retailer_users.to_a
      KarixNotificationHelper.broadcast_data(current_retailer, agents)
      render status: 200, json: { message: @message }
    else
      render status: 500, json: { message: 'Error al actualizar mensaje' }
    end
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
      unless current_retailer.positive_balance?
        render status: 401,
               json: balance_error
        return
      end
    end
end
