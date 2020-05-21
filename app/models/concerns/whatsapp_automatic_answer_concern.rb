module WhatsappAutomaticAnswerConcern
  extend ActiveSupport::Concern

  included do
    after_create :send_welcome_message
    after_create :send_inactive_message
  end

  private

    def send_welcome_message
      welcome_message = retailer.whatsapp_welcome_message
      total_messages = customer.total_whatsapp_messages
      return unless total_messages == 1 && welcome_message && direction == 'inbound'

      params = {
        message: welcome_message.message
      }

      service = "send_#{retailer.karix_integrated? ? 'karix' : 'gupshup'}_notification"
      send(service, params)
    end

    def send_inactive_message
      inactive_message = retailer.whatsapp_inactive_message
      before_last_message = customer.before_last_whatsapp_message
      return unless check_for_inactive_sent(inactive_message, before_last_message)

      params = {
        message: inactive_message.message
      }

      service = "send_#{retailer.karix_integrated? ? 'karix' : 'gupshup'}_notification"
      send(service, params)
    end

    def send_karix_notification(params)
      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(retailer, customer, params, 'text')
      return if response['error'].present?

      message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
      message.save

      karix_helper.broadcast_data(retailer, retailer.retailer_users.to_a, message)
    end

    def send_gupshup_notification(params)
      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(retailer, customer)
      gws.send_message(type: 'text', text: params[:message])
    end

    def send_message?(before_last_message, inactive_message)
      hours = ((created_at - before_last_message.created_at) / 3600).to_i

      hours >= inactive_message.interval
    end

    def check_for_inactive_sent(inactive_message, before_last_message)
      inactive_message && direction == 'inbound' && before_last_message &&
        send_message?(before_last_message, inactive_message)
    end
end