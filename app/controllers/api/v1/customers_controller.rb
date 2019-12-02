class Api::V1::CustomersController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!
  before_action :set_customer, except: :index

  def index
    @customers = current_retailer.customers.facebook_customers.active
    render status: 200, json: { customers: @customers }
  end

  def messages
    render status: 200, json: { messages: @customer.facebook_messages }
  end

  def create_message
    message = FacebookMessage.new(
      customer: @customer,
      uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      text: params[:message],
      sent_from_mercately: true
    )
    if message.save
      serialized_data = ActiveModelSerializers::Adapter::Json.new(
        FacebookMessageSerializer.new(message)
      ).serializable_hash
      FacebookMessagesChannel.broadcast_to @customer, serialized_data
      head :ok
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def message_params
      params.require(:facebook_message).permit(:text)
    end
end
