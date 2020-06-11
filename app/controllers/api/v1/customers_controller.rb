class Api::V1::CustomersController < ApplicationController
  # TODO: RENAME TO FACEBOOKCHATSCONTROLLER
  include CurrentRetailer
  include ActionView::Helpers::TextHelper
  before_action :authenticate_retailer_user!
  before_action :sanitize_params, only: [:update]
  before_action :set_customer, except: [:index, :set_message_as_read, :fast_answers_for_messenger]

  def index
    customers = if current_retailer_user.admin?
                  current_retailer.customers
                elsif current_retailer_user.agent?
                  filtered_customers = current_retailer_user.customers
                  Customer.where(id: filtered_customers.pluck(:id))
                end

    @customers = customers.facebook_customers.active
      .select('customers.*, max(facebook_messages.created_at) as recent_message_date')
      .joins(:facebook_messages).group('customers.id').order('recent_message_date desc').page(params[:page])

    @customers = @customers.by_search_text(params[:searchString]) if params[:searchString]

    render status: 200, json: {
      customers: @customers.as_json(methods:
        [
          :unread_message?,
          :last_messenger_message,
          :assigned_agent
        ]
      ),
      total_customers: @customers.total_pages
    }
  end

  def show
    render status: 200, json: { customer: @customer.as_json(methods: [:emoji_flag]) }
  end

  def update
    if @customer.update(customer_params)
      render status: 200, json: { customer: @customer.as_json(methods: [:emoji_flag]) }
    else
      render status: 400, json: { customer: @customer.as_json(methods: [:emoji_flag]), errors: @customer.errors }
    end
  end

  def messages
    facebook_helper = FacebookNotificationHelper
    @messages = @customer.facebook_messages
    @messages.customer_unread.update_all(date_read: Time.now)
    @messages = @messages.order(created_at: :desc).page(params[:page])
    @customer.update_attribute(:unread_messenger_chat, false)
    facebook_service.send_read_action(@customer.psid, 'mark_seen')

    facebook_helper.broadcast_data(
      current_retailer,
      current_retailer.retailer_users.to_a,
      nil,
      @customer.agent_customer,
      @customer
    )
    render status: 200, json: {
      messages: @messages.to_a.reverse,
      agent_list: current_retailer.team_agents,
      total_pages: @messages.total_pages
    }
  end

  def create_message
    message = FacebookMessage.new(
      customer: @customer,
      sender_uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      text: params[:message],
      sent_from_mercately: true,
      sent_by_retailer: true,
      retailer_user: current_retailer_user
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
      filename: File.basename(params[:file_data].original_filename),
      retailer_user: current_retailer_user
    )
    render status: 200, json: { message: message } if message.save
  end

  def set_message_as_read
    facebook_helper = FacebookNotificationHelper
    @message = FacebookMessage.find(params[:id])
    @message.update_column(:date_read, Time.now)
    facebook_service.send_read_action(@message.customer.psid, 'mark_seen')

    facebook_helper.broadcast_data(current_retailer, current_retailer.retailer_users.to_a)
    render status: 200, json: { message: @message }
  end

  # Filtra las plantillas para messenger por titulo o respuesta
  def fast_answers_for_messenger
    templates = current_retailer.templates.for_messenger.where('title ILIKE ?' \
      ' OR answer ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%").page(params[:page])

    serialized = Api::V1::TemplateSerializer.new(templates)
    render status: 200, json: { templates: serialized, total_pages: templates.total_pages }
  end

  def accept_opt_in
    @customer.send_for_opt_in = true
    return render status: 200, json: {} if @customer.accept_opt_in!

    render status: 400, json: { error: 'Error al aceptar opt-in de este cliente, intente nuevamente' }
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def sanitize_params
      params[:customer].each_pair do |param|
        params[:customer][param.first] = strip_tags(params[:customer][param.first]).squish if
          params[:customer][param.first]
      end
    end

    def facebook_service
      @facebook_service ||= Facebook::Messages.new(current_retailer.facebook_retailer)
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
