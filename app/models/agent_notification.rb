class AgentNotification < ApplicationRecord
  belongs_to :customer
  belongs_to :retailer_user

  validates_presence_of :customer, :retailer_user

  enum status: %i[unread read]

  def self.mark_by_customer_as_read!(customer_id, notification_type)
    unread.where(customer: customer_id, notification_type: notification_type).map do |notification|
      notification.read!
      notification.id
    end
  end
end
