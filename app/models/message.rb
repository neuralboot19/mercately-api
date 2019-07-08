class Message < ApplicationRecord
  self.table_name = 'questions'
  default_scope -> { where('questions.order_id IS NOT NULL') }

  belongs_to :order
  belongs_to :customer
  belongs_to :sender, primary_key: :sender_id, class_name: 'RetailerUser'
  delegate :retailer_id, :retailer, to: :customer
end
