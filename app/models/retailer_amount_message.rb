class RetailerAmountMessage < ApplicationRecord
  belongs_to :retailer
  belongs_to :retailer_user, required: false

  validates_presence_of :calculation_date
end