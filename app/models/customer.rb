class Customer < ApplicationRecord
  paginates_per 2
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :facebook_messages, dependent: :destroy

  validates_uniqueness_of :psid, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  before_save :update_valid_customer

  enum id_type: %i[cedula pasaporte ruc]

  scope :active, -> { where(valid_customer: true) }
  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :facebook_customers, -> { where.not(psid: nil) }

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

  def full_name
    "#{first_name} #{last_name}"
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

  def unread_message?
    facebook_messages.where(sent_from_mercately: false).last&.date_read.blank?
  end

  def last_message_received_date
    facebook_messages.where(sent_from_mercately: false).last.created_at
  end

  def range_earnings(start_date, end_date)
    orders.success.where(created_at: start_date..end_date).sum(&:total).to_f.round(2)
  end

  def range_items_bought(start_date, end_date)
    orders.success.joins(:order_items).where(created_at: start_date..end_date)
      .sum('order_items.quantity')
  end

  private

    def update_valid_customer
      return if valid_customer?

      self.valid_customer = first_name.present? || last_name.present? || email.present?
    end
end
