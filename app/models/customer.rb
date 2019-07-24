class Customer < ApplicationRecord
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy

  enum id_type: [:cedula, :pasaporte, :ruc]

  def name
    "#{first_name} #{last_name}"
  end
end
