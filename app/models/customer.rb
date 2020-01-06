class Customer < ApplicationRecord
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_save :update_valid_customer
  after_create :generate_web_id

  enum id_type: %i[cedula pasaporte ruc]

  scope :active, -> { where(valid_customer: true) }
  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }

  ransacker :sort_by_completed_orders do
    Arel.sql('coalesce((select count(orders.id) as total from orders where ' \
      'orders.customer_id = customers.id and orders.status = 1), 0)')
  end

  ransacker :sort_by_pending_orders do
    Arel.sql('coalesce((select count(orders.id) as total from orders where ' \
      'orders.customer_id = customers.id and orders.status = 0), 0)')
  end

  ransacker :sort_by_canceled_orders do
    Arel.sql('coalesce((select count(orders.id) as total from orders where ' \
      'orders.customer_id = customers.id and orders.status = 2), 0)')
  end

  ransacker :sort_by_total do
    Arel.sql('coalesce((select sum(orders.total_amount) as total from orders where ' \
      'orders.customer_id = customers.id and orders.status = 1), 0)')
  end

  def earnings
    orders.success.map(&:total).sum.to_f.round(2)
  end

  def generate_phone
    return unless phone.blank? && meli_customer&.phone.present?

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

  def range_earnings(start_date, end_date)
    orders.success.where(created_at: start_date..end_date).sum(&:total).to_f.round(2)
  end

  def range_items_bought(start_date, end_date)
    orders.success.joins(:order_items).where(created_at: start_date..end_date)
      .sum('order_items.quantity')
  end

  def to_param
    web_id
  end

  private

    def update_valid_customer
      return if valid_customer?

      self.valid_customer = full_name.present? || email.present?
    end

    def generate_web_id
      update web_id: retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end
end
