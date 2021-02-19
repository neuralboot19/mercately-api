class HubspotField < ApplicationRecord
  belongs_to :retailer
  has_one :customer_hubspot_field, dependent: :destroy

  scope :not_taken, -> { where(taken: false) }

  validates :hubspot_field, uniqueness: { scope: :retailer_id }
end
