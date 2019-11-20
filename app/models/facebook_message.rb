class FacebookMessage < ApplicationRecord
  belongs_to :facebook_retailer
  belongs_to :customer
  validates_uniqueness_of :mid, allow_blank: true
  after_create :send_facebook_message

  private

    def send_facebook_message
      Facebook::Messages.new(facebook_retailer).send_message(id_client, text) if sent_from_mercately
    end
end
