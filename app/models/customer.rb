class Customer < ApplicationRecord
  belongs_to :retailer
  has_one :meli_customer, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy

  def name
    "#{first_name} #{last_name}"
  end
end
