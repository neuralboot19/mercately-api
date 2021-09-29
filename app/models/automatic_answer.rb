class AutomaticAnswer < ApplicationRecord
  belongs_to :retailer

  validates_presence_of :retailer, :message, :status, :message_type, :platform

  enum message_type: %i[new_customer inactive_customer]
  enum status: %i[active inactive]
  enum platform: %i[whatsapp messenger instagram]

  INTERVALS = [['12 horas', 12], ['24 horas', 24], ['48 horas', 48], ['72 horas', 72], ['96 horas', 96]].freeze
end
