class Api::V1::ChatsController < Api::ApiController
  include CurrentRetailer
  before_action :set_customer

  def change_chat_status
    if @customer.change_status_chat(current_retailer_user, permit_params)
      render status: :ok, json: { customer: @customer }
      return
    end

    render status: :unprocessable_entity, json: { message: 'No fue posible cambiar el status del chat' }
  end

  private

    def permit_params
      params.require(:chat).permit(
        :customer_id,
        :status_chat
      )
    end

    def set_customer
      @customer = Customer.find(permit_params[:customer_id])
    end
end
