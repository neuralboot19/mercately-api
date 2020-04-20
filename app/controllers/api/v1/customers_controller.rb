class Api::V1::CustomersController < ApplicationController
  # TODO RENAME TO FACEBOOKCHATSCONTROLLER
  include CurrentRetailer
  include ActionView::Helpers::TextHelper
  before_action :authenticate_retailer_user!
  before_action :sanitize_params, only: [:update]
  before_action :set_customer, except: [:index, :set_message_as_readed]

  def index
    @customers = current_retailer.customers.facebook_customers.active
      .select('customers.*, max(facebook_messages.created_at) as recent_message_date')
      .joins(:facebook_messages).group('customers.id').order('recent_message_date desc').page(params[:page])

    @customers = @customers.by_search_text(params[:customerSearch]) if params[:customerSearch]

    render status: 200, json: { customers: @customers.as_json(methods: :unread_message?), total_customers: @customers.total_pages }
  end

  def show
    render status: 200, json: { customer: @customer }
  end

  def update
    if @customer.update(customer_params)
      render status: 200, json: { customer: @customer }
    else
      render status: 400, json: { error: 'error updating customer' }
    end
  end

  def messages
    facebook_helper = FacebookNotificationHelper
    @messages = @customer.facebook_messages
    @messages.unreaded.update_all(date_read: Time.now)
    @messages = @messages.order(created_at: :desc).page(params[:page])

    retailer = @customer.retailer
    facebook_helper.broadcast_data(retailer, retailer.retailer_users.to_a)
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
    render status: 200, json: { message: message } if message.save
  end

  def send_img
    message = FacebookMessage.new(
      customer: @customer,
      sender_uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      file_data: params[:file_data].tempfile.path,
      sent_from_mercately: true,
      sent_by_retailer: true,
      filename: File.basename(params[:file_data].original_filename)
    )
    render status: 200, json: { message: message } if message.save
  end

  def set_message_as_readed
    facebook_helper = FacebookNotificationHelper
    @message = FacebookMessage.find(params[:id])
    @message.update_column(:date_read, Time.now)

    retailer = @message.customer.retailer
    facebook_helper.broadcast_data(retailer, retailer.retailer_users.to_a)
    render status: 200, json: { message: @message }
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def message_params
      params.require(:facebook_message).permit(:text)
    end

    def sanitize_params
      params[:customer].each_pair do |param|
        params[:customer][param.first] = strip_tags(params[:customer][param.first]).squish if params[:customer][param.first]
      end
    end

    def customer_params
      params.require(:customer).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :id_type,
        :id_number,
        :address,
        :city,
        :state,
        :zip_code,
        :country_id,
        :notes
      )
    end
end
