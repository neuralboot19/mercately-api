class FacebookMessage < ApplicationRecord
  belongs_to :facebook_retailer
  belongs_to :customer
  belongs_to :retailer_user, required: false

  validates_uniqueness_of :mid, allow_blank: true

  after_create :sent_by_retailer?
  after_create :send_facebook_message
  after_create :broadcast_to_counter_channel
  after_create :send_welcome_message
  after_create :send_inactive_message

  scope :customer_unread, -> { where(date_read: nil, sent_by_retailer: false) }
  scope :retailer_unread, -> { where(date_read: nil, sent_by_retailer: true) }
  scope :unread, -> { where(date_read: nil) }

  private

    def sent_by_retailer?
      update_columns(sent_by_retailer: true) if sender_uid == facebook_retailer.uid
    end

    def send_facebook_message
      return unless sent_from_mercately

      m = if text.present?
            Facebook::Messages.new(facebook_retailer).send_message(id_client, text)
          elsif file_data.present?
            Facebook::Messages.new(facebook_retailer).send_attachment(id_client, file_data, filename)
          end
      update_column(:mid, m['message_id'])
    end

    def broadcast_to_counter_channel
      facebook_helper = FacebookNotificationHelper
      retailer = facebook_retailer.retailer
      facebook_helper.broadcast_data(retailer, retailer.retailer_users.to_a, self)
    end

    def send_welcome_message
      retailer = facebook_retailer.retailer
      welcome_message = retailer.messenger_welcome_message
      total_messages = customer.total_messenger_messages
      return unless total_messages == 1 && welcome_message && sent_by_retailer == false

      send_messenger_notification(welcome_message.message)
    end

    def send_inactive_message
      retailer = facebook_retailer.retailer
      inactive_message = retailer.messenger_inactive_message
      before_last_message = customer.before_last_messenger_message

      return unless inactive_message && sent_by_retailer == false && before_last_message &&
                    send_message?(before_last_message, inactive_message)

      send_messenger_notification(inactive_message.message)
    end

    def send_messenger_notification(message)
      FacebookMessage.create(
        customer: customer,
        sender_uid: facebook_retailer.uid,
        id_client: id_client,
        facebook_retailer: facebook_retailer,
        text: message,
        sent_from_mercately: true,
        sent_by_retailer: true
      )
    end

    def send_message?(before_last_message, inactive_message)
      hours = ((created_at - before_last_message.created_at) / 3600).to_i

      hours >= inactive_message.interval
    end
end
