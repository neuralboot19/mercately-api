module PushNotificationable
  extend ActiveSupport::Concern

  included do
    after_create :send_push_notifications
  end

  private

    def send_push_notifications
      # only inbound messages will be notified
      if self.class == GupshupWhatsappMessage || self.class == KarixWhatsappMessage
        return unless direction == 'inbound'
      elsif self.class == FacebookMessage || self.class == InstagramMessage
        return if sent_by_retailer
      end


      users = users_to_be_notified
      return true unless users.any?

      tokens = users_tokens(users)
      return true if tokens.blank?

      channel = if customer.ws_active
                  'whatsapp'
                elsif customer.messenger?
                  'messenger'
                elsif customer.instagram?
                  'instagram'
                end
      Retailers::MobilePushNotificationJob.perform_later(tokens, message_info, customer_id, channel)
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
       customer_retailer.retailer_users.select { |ru| ru.retailer_admin } |
       customer_retailer.retailer_users.select { |ru| ru.retailer_supervisor }
    end
end
