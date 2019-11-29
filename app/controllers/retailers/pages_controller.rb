class Retailers::PagesController < RetailersController
  def dashboard
    if params[:search] && params[:search][:range].present?
      @start_date, @end_date = params[:search][:range].split(' - ')
    else
      @start_date = Date.today.beginning_of_month.strftime('%d/%m/%Y')
      @end_date = Date.today.strftime('%d/%m/%Y')
    end
    @orders = Order.where(customer_id: current_retailer.customers.ids)
    @orders_range = @orders.range_between(@start_date, @end_date)
    @orders_count = @orders_range.count
    @customers = current_retailer.customers.range_between(@start_date, @end_date)
    @orders_total = @orders.count
    @profit_total = @orders.sum { |ord| ord.total_amount || 0 }
    @success_orders_count = Order.success.where(customer_id: current_retailer.customers.ids).count
    @pending_orders_count = Order.pending.where(customer_id: current_retailer.customers.ids).count
    @cancelled_orders_count = Order.cancelled.where(customer_id: current_retailer.customers.ids).count
    @incoming_total = @orders_range.group_by_day(:created_at).sum(:total_amount)
    @better_products = current_retailer.products.joins(:orders).group('products.id, orders.id')
      .order('COUNT(orders.id)').limit(5).map { |p| { name: p.title, data: p.orders.group_by_day(:created_at).count } }
    @better_customers = @customers.joins(:orders).group('customers.id, orders.id')
      .order('COUNT(orders.id)').limit(5).map { |c| [c.full_name, c.orders.count] }
    @total_chats = Message.where(customer_id: current_retailer.customers.ids, answer: nil).count
    @total_questions = Question.where(customer_id: current_retailer.customers.ids).count
  end
end
