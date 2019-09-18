class Message < ApplicationRecord
  self.table_name = 'questions'
  default_scope -> { where('questions.order_id IS NOT NULL') }

  belongs_to :order
  belongs_to :customer
  belongs_to :sender, foreign_key: :sender_id, class_name: 'RetailerUser', optional: true
  delegate :retailer_id, :retailer, to: :customer

  def self.latest_message_sent_by(order_id, user_id)
    where(order_id: order_id, sender_id: user_id).last
  end
end
