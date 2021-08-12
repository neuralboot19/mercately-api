class PaymentMethod < ApplicationRecord
  belongs_to :retailer
  has_many :stripe_transactions

  validates :stripe_pm_id, :retailer, :payment_type, :payment_payload, presence: true

  def card_type
    JSON.parse(payment_payload).try(:[], 'card').try(:[], 'brand')
  end
end
