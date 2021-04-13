namespace :customers do
  task update_last_interaction_gupshup: :environment do
    ActiveRecord::Base.connection.exec_query('UPDATE customers c set ws_active = true, ' \
    'last_chat_interaction = t.max_date ' \
    'FROM (SELECT customer_id, MAX(gsm.created_at) as max_date FROM gupshup_whatsapp_messages gsm ' \
    'GROUP BY gsm.customer_id) t WHERE t.customer_id = c.id')
  end

  task update_last_interaction_karix: :environment do
    ActiveRecord::Base.connection.exec_query('UPDATE customers c set ws_active = true, ' \
    'last_chat_interaction = t.max_date ' \
    'FROM (SELECT customer_id, MAX(km.created_time) as max_date FROM karix_whatsapp_messages km ' \
    'GROUP BY km.customer_id) t WHERE t.customer_id = c.id')
  end

  task update_last_interaction_messenger: :environment do
    ActiveRecord::Base.connection.exec_query('UPDATE customers c ' \
    'set last_chat_interaction = t.max_date ' \
    'FROM (SELECT customer_id, MAX(fm.created_at) as max_date FROM facebook_messages fm ' \
    'GROUP BY fm.customer_id) t WHERE t.customer_id = c.id')
  end
end
