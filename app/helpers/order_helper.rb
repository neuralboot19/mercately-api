module OrderHelper
  def disabled_statuses
    return %w[cancelled] if @order.new_record?
    return [] if @order.status == 'pending'
    return %w[pending success cancelled] if @order.status == 'cancelled'
    return %w[pending] if @order.status == 'success'
  end
end
