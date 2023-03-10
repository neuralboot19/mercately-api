class Api::V1::AgentCustomersController < Api::ApiController
  include CurrentRetailer
  before_action :set_agent_customer, only: [:update]

  def update
    return if will_be_destroyed?

    former_agent = nil
    # Si el cliente ya habia tenido un agente asignado
    unless @agent_customer.new_record?
      # Se guarda temporalmente el agente anterior
      former_agent = @agent_customer.retailer_user

      # Y se asigna el nuevo agente
      @agent_customer.retailer_user_id = assign_agent_params[:retailer_user_id]
      @agent_customer.team_assignment_id = nil
    end

    # Si no hay problemas al guardar
    if @agent_customer.save
      @customer = @agent_customer.customer
      # Se preparan los agentes que van a ser notificados
      if former_agent.present?
        agents = [
          @agent_customer.retailer_user,
          former_agent
        ].compact # <---Se eliminan los valores nulos si es que es un nuevo registro

        data = [
          current_retailer,
          agents,
          @agent_customer,
          @customer
        ]
      else
        data = [
          current_retailer,
          current_retailer.retailer_users.to_a,
          @agent_customer,
          @customer
        ]
      end

      chat_service = assign_agent_params.try(:[], :chat_service)
      # Se envian las notificaciones
      case chat_service
      when 'facebook', 'instagram'
        data.insert(2, nil)
        data << chat_service if chat_service == 'instagram'
        @customer.update_attribute(:unread_messenger_chat, true)
        facebook_helper = FacebookNotificationHelper
        facebook_helper.broadcast_data(*data)
        AgentNotificationHelper.notify_agent(data[3], chat_service)
      when 'whatsapp'
        @customer.update_attribute(:unread_whatsapp_chat, true)
        if current_retailer.gupshup_integrated?
          gnhm = Whatsapp::Gupshup::V1::Helpers::Messages.new
          gnhm.notify_agent!(*data)
          AgentNotificationHelper.notify_agent(data[2], 'whatsapp')
        elsif current_retailer.karix_integrated?
          data.insert(2, nil)
          KarixNotificationHelper.broadcast_data(*data)
        end
      end

      # Se responde con un estado 200 y un mensaje satisfactorio
      render status: 200, json: { message: 'Nuevo agente asignado satisfactoriamente' }
    else
      # Si hubo algun problema se envia un error 500 con un mensaje
      render status: 500, json: { message: 'El agente no pudo ser asignado, intente de nuevo' }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_agent_customer
      @agent_customer = AgentCustomer.where(customer_id: params[:id]).first_or_initialize do |ac|
        ac.retailer_user_id = assign_agent_params[:retailer_user_id]
      end
    end

    def assign_agent_params
      params.require(:agent).permit(:retailer_user_id, :chat_service)
    end

    def will_be_destroyed?
      if assign_agent_params[:retailer_user_id].nil?
        # Se elimina el agente asignado si se recibe nil
        @agent_customer.destroy!

        data = [
          current_retailer,
          current_retailer.retailer_users.to_a,
          nil,
          @agent_customer.customer
        ]

        chat_service = assign_agent_params.try(:[], :chat_service)
        # Se envian las notificaciones
        case chat_service
        when 'facebook', 'instagram'
          data.insert(2, nil)
          data << chat_service if chat_service == 'instagram'
          facebook_helper = FacebookNotificationHelper
          facebook_helper.broadcast_data(*data)
        when 'whatsapp'
          if current_retailer.karix_integrated?
            data.insert(2, nil)
            KarixNotificationHelper.broadcast_data(*data)
          elsif current_retailer.gupshup_integrated?
            gnhm = Whatsapp::Gupshup::V1::Helpers::Messages.new()
            gnhm.notify_agent!(*data)
          end
        end

        render status: 200, json: { message: 'Esta conversaci??n no tiene agente asignado' }
        return true
      end
      false
    end
end
