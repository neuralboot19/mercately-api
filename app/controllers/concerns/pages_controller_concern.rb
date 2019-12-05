module PagesControllerConcern
  extend ActiveSupport::Concern

  # Carga la informacion para el tab Vision General del dashboard
  def general_info
    @orders = Order.where(customer_id: current_retailer.customers.ids)
    @orders_range = @orders.range_between(@start_date, @end_date)
    @orders_count = @orders_range.count
    @profit_total = @orders_range.success.sum { |ord| ord.total_amount || 0 }.to_f.round(2)
    @success_orders_count = @orders_range.success.where(customer_id: current_retailer.customers.ids).count
    @pending_orders_count = @orders_range.pending.where(customer_id: current_retailer.customers.ids).count
    @cancelled_orders_count = @orders_range.cancelled.where(customer_id: current_retailer.customers.ids).count
    @incoming_total = @orders_range.success.group_by_day(:created_at).sum(:total_amount)
    @chats = Message.where(customer_id: current_retailer.customers.ids, answer: nil)
    @total_chats = @chats.range_between(@start_date, @end_date)
      .where(customer_id: current_retailer.customers.ids, answer: nil).count
    @questions = Question.where(customer_id: current_retailer.customers.ids)
    @total_questions = @questions.range_between(@start_date, @end_date)
      .where(customer_id: current_retailer.customers.ids).count
  end

  # Productos mas vendidos
  def best_sold_products
    q = { orders_status_eq: 1, orders_created_at_gteq: @start_date, orders_created_at_lteq:
      @end_date, s: 'sort_by_earned desc' }
    @best_products = current_retailer.products.ransack(q).result.group('products.id').limit(10).with_attached_images
  end

  # Categorias mas vendidas
  def best_categories
    q = { orders_status_eq: 1, orders_created_at_gteq: @start_date, orders_created_at_lteq: @end_date }
    category_ids = current_retailer.products.ransack(q).result.pluck(:category_id).uniq
    @best_categories = Category.joins(products: { order_items: :order })
      .where(id: category_ids, products: { retailer_id: current_retailer.id }, orders: { status: 1, created_at:
      @start_date.to_datetime..@end_date.to_datetime }).group(:id).order('sum(order_items.quantity * ' \
      'order_items.unit_price) desc')
  end

  # Mejores clientes
  def best_clients
    q = { orders_status_eq: 1, orders_created_at_gteq: @start_date, orders_created_at_lteq:
      @end_date, s: 'sort_by_total desc' }
    @best_clients = current_retailer.customers.ransack(q).result.group('customers.id').limit(10)
  end
end
