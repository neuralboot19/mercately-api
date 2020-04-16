class KarixWhatsappMessage < ApplicationRecord
  belongs_to :retailer
  belongs_to :customer

  after_create :substract_from_balance

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }

  private
    def substract_from_balance
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
