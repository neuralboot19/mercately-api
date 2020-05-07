class GupshupTemporalMessageState
  include Mongoid::Document
  include Mongoid::Timestamps

  field :whatsapp_message_id, type: String
  field :event, type: Integer
  field :retailer_id, type: Integer
  field :destination, type: String
  field :event_timestamp, type: Integer

  # before_create :set_status

  def retailer
    Retailer.find_by_id(self.retailer_id)
  end

  # Statusses beging from 2 to match GupshupWhatsappMessage model status field
  def enqueued?
    self.event == 2
  end

  def sent?
    self.event == 3
  end

  def delivered?
    self.event == 4
  end

  def read?
    self.event == 5
  end

  def status
    case self.event
    when 5
      :read
    when 4
      :delivered
    when 3
      :sent
    when 2
      :enqueued
    end
  end
end
