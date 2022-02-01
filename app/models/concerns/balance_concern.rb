module BalanceConcern
  extend ActiveSupport::Concern

  included do
    after_create :substract_from_balance, unless: -> (obj) { obj.status == 'failed' }
  end

  private

    def substract_from_balance
      return if retailer.unlimited_account && (direction == 'inbound' || message_type == 'conversation')
      return unless status != 'failed'

      amount = retailer.send("ws_#{message_type}_cost")

      chat_open = customer.is_chat_open?
      update_cost(amount, chat_open)
      retailer.ws_balance -= amount unless chat_open

      if retailer.ws_balance <= retailer.ws_next_notification_balance &&
         retailer.ws_next_notification_balance > 0
        will_send_notification = true
      end

      if retailer.ws_balance <= retailer.ws_next_notification_balance &&
         retailer.ws_next_notification_balance > 0
        retailer.ws_next_notification_balance -= 0.5
      end

      retailer.save
      send_running_out_balance_email if will_send_notification
    end

    # Sends a running out balance notification email
    def send_running_out_balance_email
      emails = retailer.admins.pluck(:email) + retailer.supervisors.pluck(:email)
      return unless emails.compact.present?

      emails.each do |email|
        RetailerMailer.running_out_balance(retailer, email).deliver_now
      end
    end

    def update_cost(amount, chat_open)
      self.cost = if chat_open
                    0
                  else
                    amount
                  end

      save
    end
end
