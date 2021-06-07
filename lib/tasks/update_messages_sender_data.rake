namespace :messages do
  task update_sender_gupshup: :environment do
    ActiveRecord::Base.connection.exec_query('UPDATE gupshup_whatsapp_messages gsm set sender_first_name = ru.first_name, ' \
    'sender_last_name = ru.last_name, sender_email = ru.email ' \
    'FROM retailer_users ru ' \
    'WHERE gsm.retailer_user_id IS NOT NULL AND ru.id = gsm.retailer_user_id')
  end

  task update_sender_karix: :environment do
    ActiveRecord::Base.connection.exec_query('UPDATE karix_whatsapp_messages km set sender_first_name = ru.first_name, ' \
    'sender_last_name = ru.last_name, sender_email = ru.email ' \
    'FROM retailer_users ru ' \
    'WHERE km.retailer_user_id IS NOT NULL AND ru.id = km.retailer_user_id')
  end

  task update_sender_messenger: :environment do
    ActiveRecord::Base.connection.exec_query('UPDATE facebook_messages fm set sender_first_name = ru.first_name, ' \
    'sender_last_name = ru.last_name, sender_email = ru.email ' \
    'FROM retailer_users ru ' \
    'WHERE fm.retailer_user_id IS NOT NULL AND ru.id = fm.retailer_user_id')
  end
end
