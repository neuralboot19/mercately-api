class Api::V1::NotesController < Api::ApiController
  include CurrentRetailer

  before_action :set_customer

  def index
    render json: set_json, status: :ok
  end

  private

    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def set_json
      arr = []
      case params[:platform]
      when 'facebook_chats'
        @customer.message_records.where(note: true).find_each do |msg|
          arr << {
            id: msg.id,
            message: msg.text,
            retailer_user: msg.retailer_user.full_name.presence || msg.retailer_user.email,
            created_at: msg.created_at
          }
        end
      when 'whatsapp_chats'
        @customer.gupshup_whatsapp_messages.where(note: true).find_each do |gwm|
          arr << {
            id: gwm.id,
            message: gwm.message_payload['payload']['payload']['text'],
            retailer_user: gwm.retailer_user.full_name.presence || gwm.retailer_user.email,
            created_at: gwm.created_at
          }
        end
      end
      { notes: arr.reverse }
    end
end
