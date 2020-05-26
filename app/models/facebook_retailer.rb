class FacebookRetailer < ApplicationRecord
  belongs_to :retailer
  has_many :facebook_messages, dependent: :destroy
  validates_uniqueness_of :uid, message: 'Ya existe una cuenta de Mercately con esta cuenta de Facebook'

  def facebook_unread_messages
    facebook_messages.includes(:customer).where(
      date_read: nil,
      sent_by_retailer: false,
      customers: { retailer_id: retailer.id }
    )
  end

  def connected?
    uid.present? && access_token.present?
  end
end
