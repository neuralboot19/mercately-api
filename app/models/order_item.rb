class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :product

  validate :check_stock

  before_update :adjust_stock, if: :will_save_change_to_quantity?
  after_save :update_order_total
  after_create :subtract_stock
  after_create :update_ml_stock

  delegate :meli_product_id, to: :product

  private

    def check_stock
      errors.add(:base, "No hay suficientes #{product.title}") if
        product.available_quantity + quantity_was.to_i < quantity
    end

    def update_ml_stock
      MercadoLibre::Products.new(product.retailer).push_update(product) if product.meli_product_id
    end

    def subtract_stock
      product.update(available_quantity: product.available_quantity - quantity,
        sold_quantity: product.sold_quantity + quantity)
    end

    def adjust_stock
      product.update(available_quantity: product.available_quantity + quantity_was - quantity,
        sold_quantity: product.sold_quantity - quantity_was + quantity)
    end

    def update_order_total
      order.update(total_amount: order.total)
    end
end
