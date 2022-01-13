class RetailerAverageResponseTime < ApplicationRecord
  belongs_to :retailer
  belongs_to :retailer_user, optional: true

  validates_presence_of :retailer, :calculation_date, :platform

  enum platform: %i[whatsapp messenger instagram]
end