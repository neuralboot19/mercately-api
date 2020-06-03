module BalanceConcern
  extend ActiveSupport::Concern

  included do
    after_create :substract_from_balance
  end

  private

    def substract_from_balance
      return if retailer.unlimited_account && (direction == 'inbound' || message_type == 'conversation')

      case self.class.name
      when 'KarixWhatsappMessage'
        return unless status != 'failed'

        amount = retailer.send("ws_#{ message_type }_cost")
      when 'GupshupWhatsappMessage'
        return unless status != 'error'

        if direction == 'outbound'
          if message_payload['type'] == 'text'
            cost_type_message = message_payload['isHSM'] == 'true' ? 'notification' : 'conversation'
          else
            cost_type_message = 'conversation'
          end
        elsif direction == 'inbound'
          cost_type_message = 'conversation'
        end

        amount = retailer.send("ws_#{ cost_type_message }_cost")
      end

      retailer.ws_balance -= amount

      if retailer.ws_balance <= retailer.ws_next_notification_balance &&
         retailer.ws_next_notification_balance > 0
        retailer.ws_next_notification_balance -= 0.5
        will_send_notification = true
      end

      retailer.save
      send_running_out_balance_email if will_send_notification
    end

    def send_running_out_balance_email
      # Sends a running out balance notification email
      RetailerMailer.running_out_balance(self.retailer).deliver_now
    end
end
