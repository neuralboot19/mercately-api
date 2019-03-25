class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :product

  before_update :adjust_stock, if: :will_save_change_to_quantity?
  after_create :subtract_stock

  protected

    def subtract_stock
      product.update(available_quantity: product.available_quantity - quantity)
    end

    def adjust_stock
      product.update(available_quantity: product.available_quantity + quantity_was - quantity)
    end
end
