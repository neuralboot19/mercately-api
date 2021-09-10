namespace :customers do
  task update_gupshup_counter: :environment do
    ActiveRecord::Base.connection.exec_query("UPDATE customers c set count_unread_messages = t.total_unread " \
    "FROM (SELECT customer_id, COUNT(gsm.id) as total_unread FROM gupshup_whatsapp_messages gsm " \
    "WHERE gsm.status NOT IN (0, 5) AND gsm.direction = 'inbound' " \
    "GROUP BY gsm.customer_id) t WHERE t.customer_id = c.id AND c.ws_active = true")
  end

  task update_karix_counter: :environment do
    ActiveRecord::Base.connection.exec_query("UPDATE customers c set count_unread_messages = t.total_unread " \
    "FROM (SELECT customer_id, COUNT(km.id) as total_unread FROM karix_whatsapp_messages km " \
    "WHERE km.status NOT IN ('failed', 'read') AND km.direction = 'inbound' " \
    "GROUP BY km.customer_id) t WHERE t.customer_id = c.id AND c.ws_active = true")
  end

  task update_messenger_counter: :environment do
    ActiveRecord::Base.connection.exec_query("UPDATE customers c set count_unread_messages = t.total_unread " \
    "FROM (SELECT customer_id, COUNT(fm.id) as total_unread FROM facebook_messages fm " \
    "WHERE fm.date_read IS NULL AND fm.sent_by_retailer = false " \
    "GROUP BY fm.customer_id) t WHERE t.customer_id = c.id AND c.pstype = 0 AND c.psid IS NOT NULL")
  end

  task update_instagram_counter: :environment do
    ActiveRecord::Base.connection.exec_query("UPDATE customers c set count_unread_messages = t.total_unread " \
    "FROM (SELECT customer_id, COUNT(igm.id) as total_unread FROM instagram_messages igm " \
    "WHERE igm.date_read IS NULL AND igm.sent_by_retailer = false " \
    "GROUP BY igm.customer_id) t WHERE t.customer_id = c.id AND c.pstype = 1 AND c.psid IS NOT NULL")
  end
end
