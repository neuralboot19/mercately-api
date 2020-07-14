class PaymentMethod < ApplicationRecord
  belongs_to :retailer

  validates :stripe_pm_id, :retailer, :payment_type, :payment_payload, presence: true
end
