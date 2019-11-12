class Retailers::PagesController < RetailersController
  def dashboard
    @orders = Order.where(customer_id: current_retailer.customers.ids)
    @orders_count = @orders.count
    @success_orders_count = Order.success.where(customer_id: current_retailer.customers.ids).count
    @pending_orders_count = Order.pending.where(customer_id: current_retailer.customers.ids).count
    @cancelled_orders_count = Order.cancelled.where(customer_id: current_retailer.customers.ids).count
    @incoming_total = @orders.where(created_at: 1.month.ago.beginning_of_month..Time.now).group_by_day(:created_at).sum(:total_amount)
    @better_products = current_retailer.products
      .joins(:orders).group('products.id, orders.id').order('COUNT(orders.id)')
      .limit(5).map { |p| { name: p.title, data: p.orders.group_by_day(:created_at).count } }
    @better_customers = current_retailer.customers.joins(:orders).group('customers.id, orders.id')
      .order('COUNT(orders.id)').limit(5)
      .map { |c| [c.full_name, c.orders.count] }
  end
end
