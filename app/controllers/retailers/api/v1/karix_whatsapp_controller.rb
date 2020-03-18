module Retailers::Api::V1
  class KarixWhatsappController < Retailers::Api::V1::ApiController
    def create
      return record_not_found unless params[:customer_id].present?
      return render_unauthorized unless params[:message].present?

      customer = current_retailer.customers.find(params[:customer_id])
      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(current_retailer, customer, params, 'text')

      set_response(500, 'Error', response['objects'][0]['error'].to_json) && return if response['objects'][0]['status'] == 'failed'

      message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0])
      message.save

      karix_helper.broadcast_data(current_retailer, message)
      set_response(200, 'Ok',response['objects'][0].to_json)
    end
  end
end
