class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :product
  belongs_to :product_variation, required: false

  before_update :adjust_stock, if: :will_save_change_to_quantity?
  before_destroy :replace_stock, prepend: true
  after_update :update_ml_stock, if: :saved_change_to_quantity?
  after_save :update_order_total
  after_create :subtract_stock
  after_create -> { update_ml_stock('create') }

  delegate :meli_product_id, to: :product

  def subtotal
    quantity * unit_price
  end

  private

    def update_ml_stock(action = 'update')
      return if action == 'create' && order.meli_order_id.present?
      return unless product.meli_product_id

      p_ml = MercadoLibre::Products.new(product.retailer)

      p_ml.push_update(product.reload)
      product.upload_variations_to_ml
    end

    def subtract_stock
      return if order.meli_order_id.present?

      if product_variation.present?
        data = product_variation.data
        data['available_quantity'] = data['available_quantity'].to_i - quantity
        data['sold_quantity'] = data['sold_quantity'].to_i + quantity
        product_variation.update(data: data)
      else
        product.update(available_quantity: product.available_quantity - quantity, sold_quantity:
          product.sold_quantity + quantity)
      end
    end

    def adjust_stock
      if product_variation.present?
        data = product_variation.data
        data['available_quantity'] = data['available_quantity'].to_i + quantity_was - quantity
        data['sold_quantity'] = data['sold_quantity'].to_i - quantity_was + quantity
        product_variation.update(data: data)
      else
        product.update(available_quantity: product.available_quantity +
          quantity_was - quantity, sold_quantity: product.sold_quantity -
          quantity_was + quantity)
      end
    end

    def update_order_total
      order.update(total_amount: order.total)
    end

    def replace_stock
      if product_variation.present?
        data = product_variation.data
        data['available_quantity'] = data['available_quantity'].to_i + quantity
        data['sold_quantity'] = data['sold_quantity'].to_i - quantity
        product_variation.update(data: data)
      else
        product.update(available_quantity: product.available_quantity +
          quantity, sold_quantity: product.sold_quantity - quantity)
      end

      update_ml_stock
    end
end
