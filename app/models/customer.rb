class Customer < ApplicationRecord
  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_many :orders, dependent: :destroy

  has_many :orders_pending, -> { pending }, class_name: 'Order', inverse_of: :customer
  has_many :orders_success, -> { success }, class_name: 'Order', inverse_of: :customer
  has_many :orders_cancelled, -> { cancelled }, class_name: 'Order', inverse_of: :customer

  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :facebook_messages, dependent: :destroy
  has_many :karix_whatsapp_messages, dependent: :destroy

  validates_uniqueness_of :psid, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_save :update_valid_customer
  after_create :generate_web_id
  before_validation :strip_whitespace

  enum id_type: %i[cedula pasaporte ruc]

  scope :active, -> { where(valid_customer: true) }
  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :facebook_customers, -> { where.not(psid: nil) }
  scope :by_search_text, (lambda do |search_text|
    where("CONCAT(REPLACE(lower(customers.first_name), '\s', ''), REPLACE(lower(customers.last_name), '\s', '')) ILIKE ?
          OR lower(customers.email) iLIKE ?
          OR lower(customers.phone) iLIKE ?",
          "%#{search_text.downcase.delete(' ')}%",
          "%#{search_text}%",
          "%#{search_text}%")
  end)

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

  def full_names
    "#{first_name} #{last_name}"
  end

  def earnings
    orders_success.map(&:total).sum.to_f.round(2)
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

  def karix_unread_message?
    last_message = karix_whatsapp_messages.where(direction: 'inbound').last
    return false unless last_message.present?

    last_message.status != 'read'
  end

  def recent_inbound_message_date
    last_message = karix_whatsapp_messages.where(direction: 'inbound').last
    return Time.now - 30.hours unless last_message.present?

    last_message.created_time
  end

  def bought_items
    product_ids = OrderItem.where(order_id: orders.success.pluck(:id)).pluck(:product_id).uniq
    Product.where(id: product_ids)
  end

  def order_items_product(product)
    orders.success.joins(:order_items).where(order_items: { product_id: product.id }).size
  end

  def earned_by_product(product)
    orders.success.joins(:order_items).where(order_items: { product_id: product.id })
      .sum('order_items.quantity * order_items.unit_price')
  end

  def to_param
    web_id
  end

  private

    def update_valid_customer
      return if valid_customer?

      self.valid_customer = first_name.present? || last_name.present? || email.present?
    end

    def generate_web_id
      update web_id: retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end

    def strip_whitespace
      self.phone = phone.strip unless phone.nil?
    end
end
