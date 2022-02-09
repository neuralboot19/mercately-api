class RetailerMostUsedTag < ApplicationRecord
  belongs_to :retailer
  belongs_to :tag

  validates_presence_of :calculation_date

  scope :range_between, -> (start_date, end_date) { where(calculation_date: start_date..end_date) }
end