class GupshupWhatsappMessage < ApplicationRecord
  include BalanceConcern
  include WhatsappAutomaticAnswerConcern

  belongs_to :retailer
  belongs_to :customer

  validates_presence_of :retailer, :customer, :status,
                        :direction, :source, :destination, :channel

  enum status: %w[error submitted enqueued sent delivered read]

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :inbound_messages, -> { where(direction: 'inbound') }
  scope :outbound_messages, -> { where(direction: 'outbound') }
  scope :notification_messages, -> { where(message_type: 'notification').where.not(status: 'error') }
  scope :conversation_messages, -> { where(message_type: 'conversation').where.not(status: 'error') }

  before_create :set_message_type

  def type
    message_payload.try(:[], 'payload').try(:[], 'type') || message_payload['type']
  end

  private

    def set_message_type
      return self.message_type = 'notification' if message_payload.try(:[], 'isHSM') == 'true'

      self.message_type = 'conversation'
    end
end
