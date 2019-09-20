class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  has_many :messages

  validates :feedback_message, length: { maximum: 160 }, if: :feedback_message?

  before_save :set_positive_rating, if: :will_save_change_to_merc_status?
  before_update :adjust_ml_stock, if: :will_save_change_to_merc_status?

  enum status: %i[confirmed payment_required payment_in_process partially_paid paid cancelled invalid_order]
  enum merc_status: %i[pending success cancelled], _prefix: true
  enum feedback_reason: %i[SELLER_OUT_OF_STOCK SELLER_DIDNT_TRY_TO_CONTACT_BUYER BUYER_NOT_ENOUGH_MONEY BUYER_REGRETS]
  enum feedback_rating: %i[positive negative neutral]

  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  delegate :retailer_id, :retailer, to: :customer

  scope :retailer_orders, lambda { |retailer_id, status|
    orders = Order.joins(:customer).where('customers.retailer_id = ?', retailer_id)
    orders = orders.where(merc_status: Order.merc_statuses[status]) if status.present? && status != 'all'
    orders
  }

  def total
    total = order_items.map do |order_item|
      order_item.unit_price * order_item.quantity
    end
    total.sum
  end

  def last_message
    return @last_message unless @last_message.blank? || @last_message.order_id != id

    @last_message = messages.order(created_at: 'DESC').first
  end

  def grouped_order_items
    grouped_orders = {}
    order_items.map { |ord| (grouped_orders[ord.product_id] ||= []) << ord }

    output = grouped_orders.map { |item| item[1] }

    output.flatten
  end

  def disabled_statuses
    return %w[cancelled] if new_record?
    return [] if merc_status == 'pending'
    return %w[pending success cancelled] if merc_status == 'cancelled'
    return %w[pending] if merc_status == 'success'
  end

  def self.build_feedback_reasons
    [['No hay disponibilidad', 'SELLER_OUT_OF_STOCK'],
     ['No se contactó al comprador', 'SELLER_DIDNT_TRY_TO_CONTACT_BUYER'],
     ['Comprador sin fondos', 'BUYER_NOT_ENOUGH_MONEY'],
     ['Comprador se retracta', 'BUYER_REGRETS']]
  end

  def unread_last_message?
    messages.where(answer: nil).last&.date_read.blank?
  end

  def last_message_received_date
    messages.where(answer: nil).last.created_at
  end

  private

    def adjust_ml_stock
      if (merc_status_was == 'pending' ||
         merc_status_was == 'success') &&
         merc_status == 'cancelled'

        update_items
        push_feedback if feedback_reason.present?
      elsif merc_status == 'success'
        push_feedback
      end
    end

    def push_feedback
      return unless meli_order_id.present?

      MercadoLibre::Orders.new(products&.first&.retailer).push_feedback(self)
    end

    def set_positive_rating
      self.feedback_rating = 'positive' if merc_status == 'success'
    end

    def update_items
      order_items.each do |order_item|
        product = order_item.product
        product_variation = order_item.product_variation

        if product_variation.present?
          data = product_variation.data
          data['available_quantity'] = data['available_quantity'].to_i + order_item.quantity unless
            order_item.from_ml? && order_item.product.meli_status != 'closed'
          data['sold_quantity'] = data['sold_quantity'].to_i - order_item.quantity
          product_variation.update(data: data)

          product.update_variations_quantities
        else
          product.update(available_quantity: product.available_quantity + order_item.quantity) unless
            order_item.from_ml? && order_item.product.meli_status != 'closed'
          product.update(sold_quantity: product.sold_quantity.to_i - order_item.quantity)
        end

        product.update_status_publishment(true)
      end
    end
end
