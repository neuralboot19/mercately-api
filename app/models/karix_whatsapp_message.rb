class KarixWhatsappMessage < ApplicationRecord
  belongs_to :retailer
  belongs_to :customer

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
end
