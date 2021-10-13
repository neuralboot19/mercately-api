class Api::V1::ChatsController < Api::ApiController
  include CurrentRetailer
  before_action :set_customer

  def change_chat_status
    if @customer.change_status_chat(current_retailer_user, permit_params)
      render status: :ok, json: { message: 'Status del chat modificado con éxito' }
      send_notification
      return
    end

    render status: :unprocessable_entity, json: { message: 'No fue posible cambiar el status del chat' }
  end

  private

    def permit_params
      params.require(:chat).permit(
        :customer_id,
        :status_chat,
        :chat_service
      )
    end

    def set_customer
      @customer = Customer.find(permit_params[:customer_id])
    end

    def send_notification
      platform = permit_params.try(:[], :chat_service)
      agents = @customer.agent.present? ? [@customer.agent] : current_retailer.retailer_users.all_customers.to_a
      data = [
        current_retailer,
        agents,
        nil,
        @customer.agent_customer,
        @customer,
        platform
      ]

      case platform
      when 'facebook', 'instagram'
        FacebookNotificationHelper.broadcast_data(*data)
      when 'whatsapp'
        if current_retailer.karix_integrated?
          KarixNotificationHelper.broadcast_data(*data)
        elsif current_retailer.gupshup_integrated?
          gnhm = Whatsapp::Gupshup::V1::Helpers::Messages.new()
          data = [current_retailer, agents, @customer]
          gnhm.notify_customer_update!(*data)
        end
      end
    end
end
