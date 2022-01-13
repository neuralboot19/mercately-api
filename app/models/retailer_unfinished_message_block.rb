class RetailerUnfinishedMessageBlock < ApplicationRecord
  belongs_to :retailer
  belongs_to :customer

  validates_presence_of :message_created_date, :platform, :message_date, :statistics

  enum platform: %i[whatsapp messenger instagram]
  enum statistics: %i[response_average new_conversations]
end
