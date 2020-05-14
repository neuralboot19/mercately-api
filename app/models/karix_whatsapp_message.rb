class KarixWhatsappMessage < ApplicationRecord
  include BalanceConcern

  belongs_to :retailer
  belongs_to :customer

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :notification_messages, -> { where(message_type: 'notification').where.not(status: 'failed') }
  scope :conversation_messages, -> { where(message_type: 'conversation').where.not(status: 'failed') }
end
