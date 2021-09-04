namespace :orders do
  task update_orders_counter: :environment do
    ActiveRecord::Base.connection.exec_query("UPDATE orders o set count_unread_messages = t.total_unread " \
    "FROM (SELECT order_id, COUNT(msg.id) as total_unread FROM questions msg " \
    "WHERE msg.date_read IS NULL AND msg.answer IS NULL AND msg.order_id IS NOT NULL " \
    "GROUP BY msg.order_id) t WHERE t.order_id = o.id AND o.meli_order_id IS NOT NULL")
  end
end
