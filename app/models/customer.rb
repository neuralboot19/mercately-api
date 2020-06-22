class Customer < ApplicationRecord
  include PhoneNumberConcern

  belongs_to :retailer
  belongs_to :meli_customer, optional: true
  has_one :agent_customer
  has_one :agent, class_name: 'RetailerUser', source: 'retailer_user', through: :agent_customer

  has_many :orders, dependent: :destroy

  has_many :orders_pending, -> { pending }, class_name: 'Order', inverse_of: :customer
  has_many :orders_success, -> { success }, class_name: 'Order', inverse_of: :customer
  has_many :orders_cancelled, -> { cancelled }, class_name: 'Order', inverse_of: :customer

  has_many :questions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :facebook_messages, dependent: :destroy
  has_many :karix_whatsapp_messages, dependent: :destroy
  has_many :gupshup_whatsapp_messages, dependent: :destroy
  has_many :customer_tags, dependent: :destroy
  has_many :tags, through: :customer_tags

  validates_uniqueness_of :psid, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :strip_whitespace
  before_save :update_valid_customer
  before_save :format_phone_number
  before_update :verify_new_phone, if: -> { phone_changed? }
  after_save :verify_opt_in
  after_create :generate_web_id

  enum id_type: %i[cedula pasaporte ruc]

  attr_accessor :ml_generated_phone, :send_for_opt_in

  scope :active, -> { where(valid_customer: true) }
  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :facebook_customers, -> { where.not(psid: nil) }
  scope :by_search_text, (lambda do |search_text|
    where("CONCAT(REPLACE(lower(customers.first_name), '\s', ''),
                  REPLACE(lower(customers.last_name), '\s', ''),
                  REPLACE(lower(customers.whatsapp_name), '\s', '')
                 ) ILIKE ?
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

    self.ml_generated_phone = true
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
    self.unread_messenger_chat || facebook_messages.where(sent_from_mercately: false).last&.date_read.blank?
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

  def unread_whatsapp_message?
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'

    last_message = self.send(messages).where(direction: 'inbound').last
    return false unless last_message.present?

    last_message.status != 'read'
  end

  def unread_whatsapp_messages
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'
    self.send(messages).unread.where(direction: 'inbound').count
  end

  def recent_inbound_message_date
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'

    last_message = self.send(messages).where(direction: 'inbound').last
    return Time.now - 30.hours unless last_message.present?

    return last_message.created_time.localtime if retailer.karix_integrated?
    last_message.created_at.localtime
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

  def self.to_csv(customers)
    attributes = %w[first_name last_name email phone id_type id_number]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      customers.each do |customer|
        csv << attributes.map { |attr| customer.send(attr) }
      end
    end
  end

  def assigned_agent
    {
      id: agent&.id || '',
      full_name: agent&.full_name || '',
      email: agent&.email || ''
    }
  end

  def last_whatsapp_message
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'
    self.send(messages).last
  end

  def recent_whatsapp_message_date
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'

    return self.send(messages).last&.created_time if retailer.karix_integrated?
    self.send(messages).last&.created_at
  end

  def recent_facebook_message_date
    facebook_messages.last&.created_at
  end

  def whatsapp_messages
    if retailer.karix_integrated?
      karix_whatsapp_messages
    elsif retailer.gupshup_integrated?
      gupshup_whatsapp_messages
    end
  end

  def emoji_flag
    return unless country.present?

    country.emoji_flag
  end

  def country
    @country ||= ISO3166::Country.new(country_id)
  end

  def split_phone
    return unless phone.present?

    begin
      Phony.split(phone.gsub('+', ''))
    rescue Phony::SplittingError => e
      Rails.logger.error(e)
      return
    end
  end

  def handle_message_events?
    retailer.whatsapp_integrated?
  end

  def total_whatsapp_messages
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'

    send(messages).count
  end

  def before_last_whatsapp_message
    messages = retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'

    send(messages).where(direction: 'inbound').second_to_last
  end

  def total_messenger_messages
    facebook_messages.count
  end

  def before_last_messenger_message
    facebook_messages.where(sent_by_retailer: false).second_to_last
  end

  def last_messenger_message
    facebook_messages.last
  end

  def accept_opt_in!
    verify_opt_in
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

    def format_phone_number
      return unless phone.present? && ml_generated_phone.blank?

      splitted_phone = split_phone
      prefix = splitted_phone&.[](0)

      aux_phone = phone.gsub('+', '')
      if country_id.present?
        if prefix == country.country_code
          self.phone = "+#{aux_phone}"
        else
          self.phone = "+#{country.country_code}#{aux_phone}"
        end
      end
    end

    def verify_new_phone
      return true if retailer.karix_integrated? || whatsapp_opt_in == false

      self.send_for_opt_in = true
      self.whatsapp_opt_in = false
    end

    def verify_opt_in
      return unless retailer.gupshup_integrated? && ActiveModel::Type::Boolean.new.cast(send_for_opt_in) == true &&
        whatsapp_opt_in == false && phone.present?

      number = self.phone_number(false)
      CSV.open("#{Rails.public_path}/#{id}_opt_in.csv", 'wb') do |csv|
        csv << [number]
      end
      info = gupshup_service.upload_list(File.open("#{Rails.public_path}/#{id}_opt_in.csv"))
      File.delete("#{Rails.public_path}/#{id}_opt_in.csv")

      return unless info.present? && info&.[](:code) == '200'

      self.send_for_opt_in = false
      update(whatsapp_opt_in: true) if info&.[](:body)&.[]('status') == true
    end

    def gupshup_service
      @gupshup_service ||= Whatsapp::Gupshup::V1::Outbound::Users.new(retailer)
    end
end
