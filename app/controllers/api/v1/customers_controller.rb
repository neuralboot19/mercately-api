class Api::V1::CustomersController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!
  before_action :set_customer, except: :index

  def index
    @customers = current_retailer.customers.facebook_customers.active
      .select('customers.*, max(facebook_messages.created_at) as recent_message_date')
      .joins(:facebook_messages).group('customers.id').order('recent_message_date desc').page(params[:page])
    render status: 200, json: { customers: @customers, total_customers: @customers.total_pages }
  end

  def show
    render status: 200, json: { customer: @customer }
  end

  def messages
    @messages = @customer.facebook_messages.order(created_at: :desc).page(params[:page])
    render status: 200, json: { messages: @messages.to_a.reverse, total_pages: @messages.total_pages }
  end

  def create_message
    message = FacebookMessage.new(
      customer: @customer,
      sender_uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      text: params[:message],
      sent_from_mercately: true,
      sent_by_retailer: true
    )
    if message.save
      render status: 200, json: { message: message }
    end
  end

  def send_img
    message = FacebookMessage.new(
      customer: @customer,
      sender_uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      file_data: params[:file_data].tempfile.path,
      sent_from_mercately: true,
      sent_by_retailer: true
    )
    if message.save
      render status: 200, json: { message: message }
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
