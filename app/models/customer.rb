class Customer < ApplicationRecord
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy
  enum id_type: [:cedula, :pasaporte, :ruc]

  before_save :update_valid_customer

  def full_name
    "#{first_name} #{last_name}"
  end

  def earnings
    order_earnings = orders.map(&:total)

    order_earnings.sum
  end

  def generate_phone
    return if self.phone.present? || meli_customer.blank?

    phone_area = meli_customer.phone_area
    phone = meli_customer.phone
    return if phone_area.blank? || phone.blank?

    phone_area = '0' + phone_area if country_id == 'EC' && phone_area[0] != '0'
    update(phone: phone_area + phone)
  end

  private

    def update_valid_customer
      return if valid_customer?

      self.valid_customer = first_name.present? || last_name.present? || email.present?
    end
end
