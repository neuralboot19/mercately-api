module PushNotificationable
  extend ActiveSupport::Concern

  included do
    after_create :send_push_notifications
  end

  private
    def send_push_notifications
      # only inbound messages will be notified
      return unless self.direction == 'inbound'

      users = users_to_be_notified
      return true unless users.any?

      tokens = users_tokens(users)
      return true if tokens.blank?

      body = "Nuevo mensaje de #{customer_name}"
      Retailers::MobilePushNotificationJob.perform_later(tokens, body, customer_id)
    end

    def customer_name
      sender = if self.class == GupshupWhatsappMessage
        self.message_payload['payload']['sender']['phone']
      elsif self.class == KarixWhatsappMessage
        self.source
      end

      self.customer.full_names.blank? ? sender : self.customer.full_names
    end

    def users_to_be_notified
      msg_customer = Customer.eager_load(:agent, retailer: [:retailer_users])
                             .find_by_id(self.customer_id)

      assigned_agent = [msg_customer.agent]
      admins = gather_admins(msg_customer.retailer)
      assigned_agent | admins
    end

    def users_tokens(users)
      tokens = users.compact.map do |ru|
        active_tokens = ru.mobile_tokens.active
        next unless active_tokens.any?
        active_tokens.pluck(:mobile_push_token)
      end
      tokens.flatten.compact
    end

    # Creado para aprovechar el eager loading
    def gather_admins(customer_retailer)
       customer_retailer.retailer_users.select { |ru| ru.retailer_admin }
    end
end
