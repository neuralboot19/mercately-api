class FacebookMessage < ApplicationRecord
  belongs_to :facebook_retailer
  belongs_to :customer

  validates_uniqueness_of :mid, allow_blank: true

  after_create :sent_by_retailer?
  after_create :send_facebook_message

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
end
