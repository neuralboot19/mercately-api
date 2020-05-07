class KarixWhatsappMessage < ApplicationRecord
  include BalanceConcern

  belongs_to :retailer
  belongs_to :customer

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :notification_messages, -> { where(message_type: 'notification').where.not(status: 'failed') }
  scope :conversation_messages, -> { where(message_type: 'conversation').where.not(status: 'failed') }

  private

    def substract_from_balance
      return unless status != 'failed'

      amount = retailer.send("ws_#{ message_type }_cost")
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
