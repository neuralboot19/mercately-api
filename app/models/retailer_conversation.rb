class RetailerConversation < ApplicationRecord
  belongs_to :retailer
  belongs_to :retailer_user, optional: true

  validates_presence_of :calculation_date
end