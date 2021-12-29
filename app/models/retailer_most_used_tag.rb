class RetailerMostUsedTag < ApplicationRecord
  belongs_to :retailer
  belongs_to :tag

  validates_presence_of :calculation_date
end