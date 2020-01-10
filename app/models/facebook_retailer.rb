class FacebookRetailer < ApplicationRecord
  belongs_to :retailer
  has_many :facebook_messages, dependent: :destroy

  def facebook_unread_messages
    facebook_messages.includes(:customer).where(
      date_read: nil,
      sent_by_retailer: false,
      customers: { retailer_id: retailer.id }
    )
  end
end
