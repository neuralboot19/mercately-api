class FacebookRetailer < ApplicationRecord
  include AddSalesChannelConcern

  belongs_to :retailer
  has_many :facebook_messages, dependent: :destroy
  validates_uniqueness_of :uid, message: 'Ya existe una cuenta de Mercately con esta cuenta de Facebook'

  after_create :add_sales_channel

  def facebook_unread_messages(retailer_user)
    messages = facebook_messages.includes(:customer).where(
      date_read: nil,
      sent_by_retailer: false,
      customers: { retailer_id: retailer.id }
    )

    return messages if retailer_user.admin? || retailer_user.supervisor?

    if retailer_user.only_assigned?
      messages.includes(customer: :agent_customer).where(agent_customers: { retailer_user_id: retailer_user.id })
    else
      messages.includes(customer: :agent_customer)
        .where(agent_customers: { retailer_user_id: [retailer_user.id, nil] })
    end
  end

  def connected?
    uid.present? && access_token.present?
  end
end
