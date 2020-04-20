class Api::V1::AgentCustomersController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!
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
    end

    # Si no hay problemas al guardar
    if @agent_customer.save
      # Se preparan los agentes que van a ser notificados
      agents = [
        @agent_customer.retailer_user,
        former_agent
      ].compact # <---Se eliminan los valores nulos si es que es un nuevo registro

      # Se envian las notificaciones
      if former_agent
        KarixNotificationHelper.broadcast_data(current_retailer, agents, nil, @agent_customer)
      else
        KarixNotificationHelper.broadcast_data(current_retailer, current_retailer.retailer_users.to_a, nil, @agent_customer)
      end

      RetailerMailer.chat_assignment_notification(@agent_customer, current_retailer_user).deliver_now if
        @agent_customer.retailer_user_id != current_retailer_user.id

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
      params.require(:agent).permit(:retailer_user_id)
    end

    def will_be_destroyed?
      if assign_agent_params[:retailer_user_id].nil?
        # Se elimina el agente asignado si se recibe nil
        @agent_customer.destroy!

        # Se envian las notificaciones
        KarixNotificationHelper.broadcast_data(current_retailer, current_retailer.retailer_users.to_a, nil,
          @agent_customer)

        render status: 200, json: { message: 'Esta conversación no tiene agente asignado' }
        return true
      end
      false
    end
end
