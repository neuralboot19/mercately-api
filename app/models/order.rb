class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  has_many :messages

  before_update :adjust_ml_stock, if: :will_save_change_to_merc_status?

  enum status: %i[confirmed payment_required payment_in_process partially_paid paid cancelled invalid_order]
  enum merc_status: %i[pending success cancelled], _prefix: true

  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  delegate :retailer_id, :retailer, to: :customer

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
    return %w[pending success cancelled] if merc_status != 'pending'
  end

  private

    def adjust_ml_stock
      return unless (merc_status_was == 'pending' ||
                    merc_status_was == 'success') &&
                    merc_status == 'cancelled'

      order_items.each do |order_item|
        product = order_item.product
        product_variation = order_item.product_variation

        if product_variation.present?
          data = product_variation.data
          data['available_quantity'] = data['available_quantity'].to_i + order_item.quantity
          data['sold_quantity'] = data['sold_quantity'].to_i - order_item.quantity
          product_variation.update(data: data)
        else
          product.update(available_quantity: product.available_quantity +
            order_item.quantity, sold_quantity: product.sold_quantity - order_item.quantity)
        end

        update_ml_stock(product)
      end
    end

    def update_ml_stock(product)
      p_ml = MercadoLibre::Products.new(product&.retailer)

      return unless product.meli_product_id

      p_ml.push_update(product.reload)
      product.upload_variations_to_ml
    end
end
