class Message < ApplicationRecord
  include WebIdGenerateableConcern

  self.table_name = 'questions'
  default_scope -> { where('questions.order_id IS NOT NULL') }

  belongs_to :order
  belongs_to :customer
  belongs_to :sender, foreign_key: :sender_id, class_name: 'RetailerUser', optional: true

  after_create :generate_web_id

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }

  delegate :retailer_id, :retailer, to: :customer

  def to_param
    web_id
  end
end
