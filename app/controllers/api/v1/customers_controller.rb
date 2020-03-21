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

    if params[:customerSearch]
      @customers = @customers.where("CONCAT(lower(customers.first_name), lower(customers.last_name)) ILIKE ?
        OR lower(customers.email) iLIKE ? 
        OR lower(customers.phone) iLIKE ?", 
        "%#{params[:customerSearch].downcase.delete(' ')}%",
        "%#{params[:customerSearch]}%",
        "%#{params[:customerSearch]}%")
    end

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
    @messages = @customer.facebook_messages
    @messages.unreaded.update_all(date_read: Time.now)
    @messages = @messages.order(created_at: :desc).page(params[:page])

    render status: 200, json: { messages: @messages.to_a.reverse, total_pages: @messages.total_pages }

    redis.publish 'new_message_counter', {identifier: '.item__cookie_facebook_messages', action: 'add', total:
      @customer.retailer.facebook_unread_messages.size, room: @customer.retailer.id}.to_json
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
    @message = FacebookMessage.find(params[:id])
    @message.update_column(:date_read, Time.now)
    render status: 200, json: { message: @message }

    redis.publish 'new_message_counter', {identifier: '.item__cookie_facebook_messages', action: 'subtract', q:
      1, total: @message.customer.retailer.facebook_unread_messages.size, room:
      @message.customer.retailer.id}.to_json
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

    def redis
      @redis ||= Redis.new()
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
