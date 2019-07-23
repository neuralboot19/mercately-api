class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  has_many :messages

  validate :check_stock
  before_update :adjust_ml_stock, if: :will_save_change_to_status?

  enum status: %i[confirmed payment_required payment_in_process partially_paid paid cancelled invalid_order]

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

    def check_stock
      o_valid = true
      order_items.map(&:product_id).uniq.each do |p_id|
        product = Product.find(p_id)
        p_order_quantity = 0
        order_items.map { |oi| oi if oi.product_id == p_id }.compact.each do |oi|
          p_order_quantity += oi.quantity
        end
        if p_order_quantity > product.available_quantity
          errors.add(:base, "No hay sufucientes #{product.title}")
          o_valid = false
        end
      end
      o_valid
    end

    def adjust_ml_stock
      return if status == 'cancelled' || status == 'invalid_order'

      order_items.each do |_order_item|
        product.update(available_quantity: product.available_quantity + quantity)
        MercadoLibre::Products.push_update(product) if product.meli_product_id
      end
    end
end
