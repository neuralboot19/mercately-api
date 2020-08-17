class AgentCustomer < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :customer

  before_save :send_push_notification

  private
    def send_push_notification
      tokens = self.retailer_user.mobile_tokens
                                 .active
                                 .pluck(:mobile_push_token)
                                 .compact

      # It is suposed that tokens should be an empty array
      # if not found any mobile push token, anyway, I rather
      # to validate this before trying to send the notification
      return true if tokens.blank?

      body = "Nuevo chat asignado - #{customer_name}"
      Retailers::MobilePushNotificationJob.perform_later(tokens, body)
    end

    def customer_name
      self.customer.full_names.blank? ? self.customer.phone : self.customer.full_names
    end
end
