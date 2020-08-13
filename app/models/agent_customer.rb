class AgentCustomer < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :customer

  after_save :send_push_notification

  private
    def send_push_notification
      return true if retailer_user_id_changed?
      tokens = self.retailer_user.mobile_tokens
                                 .active
                                 .pluck(:mobile_push_token)

      body = "Nuevo chat asignado - #{customer_name}"
      Retailers::MobilePushNotificationJob.perform_later(tokens, body)
    end

    def customer_name
      self.customer.full_names.blank? ? self.customer.phone : self.customer.full_names
    end
end
