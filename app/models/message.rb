class Message < ApplicationRecord
  self.table_name = 'questions'
  default_scope -> { where('questions.order_id IS NOT NULL') }

  belongs_to :order
  belongs_to :customer
  belongs_to :sender, foreign_key: :sender_id, class_name: 'RetailerUser', optional: true
  delegate :retailer_id, :retailer, to: :customer

  # Se especifica la cantidad porque al tratarse de Array, no toma el default
  PER_PAGE = 25

  scope :order_messages, lambda { |messages|
    messages.sort_by { |o| [o.unread_last_message? ? 0 : 1, Time.now - o.last_message_received_date] }
  }

  def self.latest_message_sent_by(order_id, user_id)
    where(order_id: order_id, sender_id: user_id).last
  end
end
