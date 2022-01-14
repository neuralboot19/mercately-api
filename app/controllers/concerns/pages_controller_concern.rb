# frozen_string_literal: true

module PagesControllerConcern
  extend ActiveSupport::Concern

  # Carga la informacion para el tab Vision General del dashboard
  def general_info
    @customer_ids = current_retailer.customers.ids
    @orders = Order.where(customer_id: @customer_ids)
    @orders_range = @orders.range_between(@start_date, @end_date)
    @first_five_orders = @orders_range.limit(5)
    @success_orders_count = @orders_range.success.where(customer_id: @customer_ids).count
  end

  # Productos mas vendidos
  def best_sold_products
    q = {
      orders_status_eq: 1,
      orders_created_at_gteq: @start_date,
      orders_created_at_lteq: @end_date,
      s: 'sort_by_earned desc'
    }
    @best_products = current_retailer.products.includes(:order_items).ransack(q).result
      .group('products.id').limit(10).with_attached_images
  end

  # Mejores clientes
  def clients
    q = {
      created_at_gteq: @start_date,
      created_at_lteq: @end_date,
      s: 'sort_by_total desc'
    }
    @clients = current_retailer.customers.ransack(q).result
  end
end
