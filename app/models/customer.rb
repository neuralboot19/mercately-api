class Customer < ApplicationRecord
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy
  enum id_type: [:cedula, :pasaporte, :ruc]

  after_save :update_valid_customer

  def full_name
    "#{first_name} #{last_name}"
  end

  def earnings
    order_earnings = orders.map(&:total)

    order_earnings.sum
  end

  private

    def update_valid_customer
      return if a_valid_customer? || a_not_valid_customer?

      update(valid_customer: first_name.present? || last_name.present? || email.present?)
    end

    def a_valid_customer?
      valid_customer && (first_name.present? || last_name.present? || email.present?)
    end

    def a_not_valid_customer?
      !valid_customer && first_name.blank? && last_name.blank? && email.blank?
    end
end
