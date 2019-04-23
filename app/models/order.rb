class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  validate :check_stock
  enum status: %i[pending completed failed]
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  delegate :retailer_id, :retailer, to: :customer

  def total
    total = order_items.map do |order_item|
      order_item.unit_price * order_item.quantity
    end
    total.sum
  end

  protected

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
end
