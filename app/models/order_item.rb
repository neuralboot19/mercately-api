class OrderItem < ApplicationRecord
  include OrderItemModelConcern
  belongs_to :order, inverse_of: :order_items
  belongs_to :product
  belongs_to :product_variation, required: false

  before_update :adjust_stock, if: :will_save_change_to_quantity?
  before_destroy :replace_stock, prepend: true
  before_destroy -> { catch_total('destroy') }
  before_save -> { catch_total('save') }
  after_update :update_ml_stock, if: :saved_change_to_quantity?
  after_commit :update_order_total
  after_create :subtract_stock
  after_create -> { update_ml_stock('create') }

  delegate :meli_product_id, to: :product

  attr_accessor :change_sold_quantity

  def subtotal
    quantity * unit_price
  end

  private

    # TODO: Move to service
    def update_ml_stock(action = 'update')
      return if action == 'create' && from_ml?
      return unless product.meli_product_id

      p_ml = MercadoLibre::Products.new(product.retailer)

      p_ml.push_update(product.reload)
      product.upload_variations_to_ml
    end

    def subtract_stock
      if product_variation.present?
        data = product_variation.data
        new_available_quantity = data['available_quantity'].to_i - quantity
        new_sold_quantity = data['sold_quantity'].to_i + quantity

        data['available_quantity'] = new_available_quantity unless from_ml?
        data['sold_quantity'] = new_sold_quantity unless subtract_sold_quantity?
        product_variation.update(data: data)

        product.update_variations_quantities
      else
        new_available_quantity = product.available_quantity - quantity
        new_sold_quantity = product.sold_quantity.to_i + quantity

        product.update(available_quantity: new_available_quantity) unless from_ml?
        product.update(sold_quantity: new_sold_quantity) unless subtract_sold_quantity?
      end

      product.update_status_publishment(true)
    end

    def adjust_stock
      if product_variation.present?
        data = product_variation.data
        data['available_quantity'] = data['available_quantity'].to_i + quantity_was - quantity
        data['sold_quantity'] = data['sold_quantity'].to_i - quantity_was + quantity
        product_variation.update(data: data)

        product.update_variations_quantities
      else
        product.update(available_quantity: product.available_quantity +
          quantity_was - quantity, sold_quantity: product.sold_quantity.to_i -
          quantity_was + quantity)
      end

      product.update_status_publishment(true)
    end

    def update_order_total
      return if @is_new && from_ml

      order.update(total_amount: @total)
    end

    def replace_stock
      if product_variation.present?
        data = product_variation.data
        data['available_quantity'] = data['available_quantity'].to_i + quantity
        data['sold_quantity'] = data['sold_quantity'].to_i - quantity
        product_variation.update(data: data)

        product.update_variations_quantities
      else
        product.update(available_quantity: product.available_quantity +
          quantity, sold_quantity: product.sold_quantity.to_i - quantity)
      end

      update_ml_stock
      product.update_status_publishment(true)
    end

    # TODO: Refactorizar para obtener el total desde la orden
    def catch_total(action)
      @total = order.total_amount || 0
      @is_new = new_record?

      @total -= if new_record?
                  0
                elsif action == 'save'
                  quantity_was * unit_price_was
                else
                  quantity * unit_price
                end

      @total += quantity * unit_price if action == 'save'
    end
end
