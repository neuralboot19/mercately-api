class GupshupWhatsappMessage < ApplicationRecord
  include BalanceConcern

  belongs_to :retailer
  belongs_to :customer

  validates_presence_of :retailer, :customer, :status,
                        :direction, :source, :destination, :channel

  enum status: %w{error submitted enqueued sent delivered read}

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :inbound_messages, -> { where(direction: 'inbound') }
  scope :outbound_messages, -> { where(direction: 'outbound') }

  def type
    message_payload['payload']['type']
  end
end
