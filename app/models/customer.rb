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
    order_earnings = orders.success.map(&:total)

    order_earnings.sum
  end

  def generate_phone
    return unless do_generate_phone?

    phone_area = ''
    if meli_customer.phone_area.present?
      phone_area = if country_id == 'EC' && meli_customer.phone_area[0] != '0'
                     "0#{meli_customer.phone_area}"
                   else
                     meli_customer.phone_area
                   end
    end

    update(phone: phone_area + meli_customer.phone)
  end

  private

    def update_valid_customer
      return if valid_customer?

      self.valid_customer = first_name.present? || last_name.present? || email.present?
    end

    def do_generate_phone?
      phone.blank? && meli_customer&.phone.present?
    end
end
