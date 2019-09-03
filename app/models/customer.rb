class Customer < ApplicationRecord
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy

  enum id_type: [:cedula, :pasaporte, :ruc]

  scope :retailer_customers, lambda { |retailer_id|
    Customer.where(retailer_id: retailer_id)
  }

  def name
    "#{first_name} #{last_name}"
  end

  def earnings
    order_earnings = orders.map(&:total)

    order_earnings.sum
  end
end
