class RetailerWhatsappConversation < ApplicationRecord
  belongs_to :retailer
  has_many :country_conversations

  validates_presence_of :year, :month
end
