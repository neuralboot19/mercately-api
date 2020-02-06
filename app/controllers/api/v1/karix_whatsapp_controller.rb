class Api::V1::KarixWhatsappController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!, except: :save_message
  before_action :set_customer, only: [:messages, :send_file, :message_read]
  protect_from_forgery :only => [:save_message]

  def index
    @customers = current_retailer.customers
      .select('customers.*, max(karix_whatsapp_messages.created_time) as recent_message_date')
      .joins(:karix_whatsapp_messages).group('customers.id').order('recent_message_date desc').page(params[:page])

    if @customers.present?
      render status: 200, json: { customers: @customers.as_json(methods:
        [:karix_unread_message?, :recent_inbound_message_date]), total_customers:
        @customers.total_pages }
    else
      render status: 404, json: { message: 'Customers not found' }
    end
  end

  def create
    customer = current_retailer.customers.find(params[:customer_id])
    response = ws_message_service.send_message(current_retailer, customer, params, 'text')

    if response['error'].present?
      render status: 500, json: { message: response['error']['message'] }
    else
      message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = ws_message_service.assign_message(message, current_retailer, response['objects'][0])
      message.save
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
    broadcast_data(current_retailer)

    if @messages.present?
      render status: 200, json: { messages: @messages.to_a.reverse, total_pages: @messages.total_pages }
    else
      render status: 404, json: { message: 'Messages not found' }
    end
  end

  def save_message
    if params['error'].present?
      render json: { message: params['error']['message'] }, status: 500
      return
    end

    retailer = Retailer.find_by(karix_account_uid: params['data']['account_uid'])

    if retailer
      message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: params['data']['uid'])
      message = ws_message_service.assign_message(message, retailer, params['data'])
      message.save
      broadcast_data(retailer, message) if message.persisted?

      render status: 200, json: { message: 'succesful' }
    else
      render status: 404, json: { message: 'Retailer not found' }
    end
  end

  def send_file
    response = ws_message_service.send_message(current_retailer, @customer, params, 'file')

    if response['error'].present?
      render status: 500, json: { message: response['error']['message'] }
    else
      render status: 200, json: { message: response['objects'][0] }
    end
  end

  def message_read
    @message = @customer.karix_whatsapp_messages.find(params[:message_id])

    if @message.update_column(:status, 'read')
      broadcast_data(current_retailer)
      render status: 200, json: { message: @message }
    else
      render status: 500, json: { message: 'Error al actualizar mensaje' }
    end
  end

  private
     # Only allow a trusted parameter "white list" through.
    def karix_whatsapp_params
      params.require(:karix_whatsapp).permit(
        :uid,
        :account_uid,
        :source,
        :destination,
        :country,
        :content_type,
        :content_text,
        :content_media_url,
        :content_media_caption,
        :content_media_type,
        :content_location_longitude,
        :content_location_latitude,
        :content_location_label,
        :content_location_address,
        :created_time,
        :sent_time,
        :delivered_time,
        :updated_time,
        :status,
        :direction,
        :channel,
        :error_code,
        :error_message
      )
    end

    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def broadcast_data(retailer, message = nil)
      total = retailer.karix_unread_whatsapp_messages.size
      CounterMessagingChannel.broadcast_to(retailer.retailer_users.where(retailer_admin: true).first, identifier:
        '.item__cookie_whatsapp_messages', total: total > 9 ? '9+' : total )

      if message.present?
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          KarixWhatsappMessageSerializer.new(message)
        ).serializable_hash
        KarixWhatsappMessagesChannel.broadcast_to message.customer, serialized_data

        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          KarixCustomerSerializer.new(message.customer)
        ).serializable_hash
        KarixCustomersChannel.broadcast_to retailer, serialized_data
      end
    end

    def ws_message_service
      @ws_message_service = Whatsapp::Karix::Messages.new
    end
end
