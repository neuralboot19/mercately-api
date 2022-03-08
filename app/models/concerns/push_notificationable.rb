module PushNotificationable
  extend ActiveSupport::Concern

  included do
    after_commit :send_push_notifications, on: :create
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
      emails = users_emails(users)

      return true if tokens.blank? && emails.blank?

      channel = case self.class.name
                when 'GupshupWhatsappMessage', 'KarixWhatsappMessage'
                  'whatsapp'
                when 'FacebookMessage'
                  'messenger'
                when 'InstagramMessage'
                  'instagram'
                end
      if tokens.any?
        # Retailers::MobilePushNotificationJob.perform_later(tokens, message_info, customer_id, channel)
        push_notification = PushNotification.new(tokens, message_info, customer_id, channel)
        push_notification.send_messages
      end

      if emails.any?
        push_notification = OneSignalPushNotification.new(emails, message_info, customer_id, channel)
        push_notification.send_messages
      end
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
    end

    def customer_name
      sender = if self.class == GupshupWhatsappMessage
                 message_payload['payload']['sender']['phone']
               elsif self.class == KarixWhatsappMessage
                 source
               end

      customer.full_names.blank? ? sender : customer.full_names
    end

    def users_to_be_notified
      msg_customer = Customer.eager_load(:agent, retailer: [:retailer_users])
        .find_by_id(customer_id)

      assigned_agent = [msg_customer.agent]
      admins = gather_admins(msg_customer.retailer)
      assigned_agent | admins
    end

    def users_tokens(users)
      tokens = users.compact.map do |ru|
        next if ru.ios?
        active_tokens = ru.mobile_tokens
        next unless active_tokens.exists?

        active_tokens.pluck(:mobile_push_token)
      end
      tokens.flatten.compact
    end

    def users_emails(users)
      emails = users.compact.map do |ru|
        next if ru.android?
        ru.email
      end
      emails.flatten.compact
    end

    # Creado para aprovechar el eager loading
    def gather_admins(customer_retailer)
      customer_retailer.retailer_users.select(&:retailer_admin) |
        customer_retailer.retailer_users.select(&:retailer_supervisor)
    end
end
