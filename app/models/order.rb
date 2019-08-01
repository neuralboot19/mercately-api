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

  private

    def adjust_ml_stock
      order_items.each do |order_item|
        product = order_item.product

        if (merc_status_was == 'pending' || merc_status_was == 'success') && merc_status == 'cancelled'
          product.update(available_quantity: product.available_quantity + order_item.quantity,
            sold_quantity: product.sold_quantity - order_item.quantity)
          update_ml_stock(product)
        elsif (merc_status == 'pending' || merc_status == 'success') && merc_status_was == 'cancelled'
          product.update(available_quantity: product.available_quantity - order_item.quantity,
            sold_quantity: product.sold_quantity + order_item.quantity)
          update_ml_stock(product)
        end
      end
    end

    def update_ml_stock(product)
      MercadoLibre::Products.new(product&.retailer).push_update(product.reload) if
        product.meli_product_id
    end
end
