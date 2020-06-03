module Retailers::Api::V1
  class KarixWhatsappController < Retailers::Api::V1::ApiController
    before_action :validate_balance, only: [:create]

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
      params_present = params[:phone_number].present? && params[:message].present? && params[:template].present?
      set_response(500, 'Error: Missing phone number and/or message and/or template') && return unless params_present

      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(current_retailer, nil, params, 'text')

      error = response['objects'][0]['status'] == 'failed'
      set_response(500, 'Error', response['objects'][0]['error'].to_json) && return if error

      message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0],
                                                               current_retailer.retailer_user)
      message.save

      agents = message.customer.agent.present? ? [message.customer.agent] : current_retailer.retailer_users.to_a
      karix_helper.broadcast_data(current_retailer, agents, message)
      set_response(200, 'Ok', format_response(response['objects'][0]))
    end

    private

      def format_response(object)
        object.slice(*KARIX_PERMITED_PARAMS).to_json
      end

      def validate_balance
        is_template = ActiveModel::Type::Boolean.new.cast(params[:template])

        return if current_retailer.unlimited_account && is_template == false
        return if current_retailer.positive_balance?

        render status: 401, json: { message: 'Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, ' \
                                              'por favor, contáctese con su agente de ventas para recargar su saldo' }
        return
      end
  end
end
