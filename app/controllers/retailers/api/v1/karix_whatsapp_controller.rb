module Retailers::Api::V1
  class KarixWhatsappController < Retailers::Api::V1::ApiController
    KARIX_PERMITED_PARAMS = %w[
      channel
      content
      direction
      status
      destination
      country
      created_time
      error
    ].freeze

    def create
      params_present = params[:phone_number].present? && params[:message].present?
      set_response(500, 'Error: Missing phone number and/or message') && return unless params_present

      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(current_retailer, nil, params, 'text')

      error = response['objects'][0]['status'] == 'failed'
      set_response(500, 'Error', response['objects'][0]['error'].to_json) && return if error

      message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0])
      message.save

      karix_helper.broadcast_data(current_retailer, message)
      set_response(200, 'Ok', format_response(response['objects'][0]))
    end

    private

      def format_response(object)
        object.slice(*KARIX_PERMITED_PARAMS).to_json
      end
  end
end
