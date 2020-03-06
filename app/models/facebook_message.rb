class FacebookMessage < ApplicationRecord
  belongs_to :facebook_retailer
  belongs_to :customer

  validates_uniqueness_of :mid, allow_blank: true

  after_create :sent_by_retailer?
  after_create :send_facebook_message
  after_create :broadcast_to_counter_channel

  scope :unreaded, -> { where(date_read: nil) }

  private

    def sent_by_retailer?
      update_columns(sent_by_retailer: true) if self.sender_uid == self.facebook_retailer.uid
    end

    def send_facebook_message
      if sent_from_mercately
        m = if text.present?
              Facebook::Messages.new(facebook_retailer).send_message(id_client, text)
            elsif file_data.present?
              Facebook::Messages.new(facebook_retailer).send_attachment(id_client, file_data)
            end
        update_column(:mid, m['message_id'])
      end
    end

    def broadcast_to_counter_channel
      redis.publish 'new_message_counter', {identifier: '.item__cookie_facebook_messages', action: 'add', total:
        facebook_retailer.retailer.facebook_unread_messages.size, room: facebook_retailer.retailer.id}.to_json
    end

    def redis
      @redis ||= Redis.new()
    end
end
