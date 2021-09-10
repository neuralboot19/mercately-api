namespace :retailer_users do
  task update_gupshup_unread: :environment do
    Retailer.where.not(gupshup_phone_number: nil, gupshup_src_name: nil, gupshup_api_key: nil).find_each do |retailer|
      admins_supervisors = retailer.admins.or(retailer.supervisors)
      admins_supervisors.update_all(whatsapp_unread: retailer.customers.active_whatsapp
        .with_unread_messages.exists?)

      retailer.retailer_users.active_agents.only_assigned_customers
        .joins('INNER JOIN agent_customers ac ON ac.retailer_user_id = retailer_users.id')
        .joins('INNER JOIN customers c ON ac.customer_id = c.id')
        .where('c.ws_active = true AND c.count_unread_messages > 0 AND c.retailer_id = ?', retailer.id)
        .update_all(whatsapp_unread: true)

      agents = retailer.retailer_users.active_agents.all_customers

      customer_ids = Customer.joins('LEFT JOIN agent_customers ac ON ac.customer_id = customers.id')
        .where('(ac.retailer_user_id IN (?) OR ac.retailer_user_id is NULL) AND customers.retailer_id = ? AND ' \
        'customers.ws_active = true AND customers.count_unread_messages > 0',
        agents.ids, retailer.id).select('distinct customers.id')

      assigned = AgentCustomer.where(customer_id: customer_ids)
      if assigned.select('distinct customer_id').size != customer_ids.size
        agents.update_all(whatsapp_unread: true)
        next
      end

      assigned_users = assigned.pluck(:retailer_user_id).uniq
      agents.where(id: assigned_users).update_all(whatsapp_unread: true) if assigned_users.present?
      agents.where.not(id: assigned_users).update_all(whatsapp_unread: false)
    end
  end

  task update_karix_unread: :environment do
    Retailer.where.not(karix_whatsapp_phone: nil, karix_account_uid: nil, karix_account_token: nil).find_each do |retailer|
      admins_supervisors = retailer.admins.or(retailer.supervisors)
      admins_supervisors.update_all(whatsapp_unread: retailer.customers.active_whatsapp
        .with_unread_messages.exists?)

      retailer.retailer_users.active_agents.only_assigned_customers
        .joins('INNER JOIN agent_customers ac ON ac.retailer_user_id = retailer_users.id')
        .joins('INNER JOIN customers c ON ac.customer_id = c.id')
        .where('c.ws_active = true AND c.count_unread_messages > 0 AND c.retailer_id = ?', retailer.id)
        .update_all(whatsapp_unread: true)

      agents = retailer.retailer_users.active_agents.all_customers

      customer_ids = Customer.joins('LEFT JOIN agent_customers ac ON ac.customer_id = customers.id')
        .where('(ac.retailer_user_id IN (?) OR ac.retailer_user_id is NULL) AND customers.retailer_id = ? AND ' \
        'customers.ws_active = true AND customers.count_unread_messages > 0',
        agents.ids, retailer.id).select('distinct customers.id')

      assigned = AgentCustomer.where(customer_id: customer_ids)
      if assigned.select('distinct customer_id').size != customer_ids.size
        agents.update_all(whatsapp_unread: true)
        next
      end

      assigned_users = assigned.pluck(:retailer_user_id).uniq
      agents.where(id: assigned_users).update_all(whatsapp_unread: true) if assigned_users.present?
      agents.where.not(id: assigned_users).update_all(whatsapp_unread: false)
    end
  end

  task update_messenger_unread: :environment do
    retailer_ids = FacebookRetailer.where(messenger_integrated: true).pluck(:retailer_id)
    Retailer.where(id: retailer_ids).find_each do |retailer|
      admins_supervisors = retailer.admins.or(retailer.supervisors)
      admins_supervisors.update_all(messenger_unread: retailer.customers.messenger
        .with_unread_messages.exists?)

      retailer.retailer_users.active_agents.only_assigned_customers
        .joins('INNER JOIN agent_customers ac ON ac.retailer_user_id = retailer_users.id')
        .joins('INNER JOIN customers c ON ac.customer_id = c.id')
        .where('c.pstype = 0 AND c.count_unread_messages > 0 AND c.retailer_id = ?', retailer.id)
        .update_all(messenger_unread: true)

      agents = retailer.retailer_users.active_agents.all_customers

      customer_ids = Customer.joins('LEFT JOIN agent_customers ac ON ac.customer_id = customers.id')
        .where('(ac.retailer_user_id IN (?) OR ac.retailer_user_id is NULL) AND customers.retailer_id = ? AND ' \
        'customers.pstype = 0 AND customers.count_unread_messages > 0',
        agents.ids, retailer.id).select('distinct customers.id')

      assigned = AgentCustomer.where(customer_id: customer_ids)
      if assigned.select('distinct customer_id').size != customer_ids.size
        agents.update_all(messenger_unread: true)
        next
      end

      assigned_users = assigned.pluck(:retailer_user_id).uniq
      agents.where(id: assigned_users).update_all(messenger_unread: true) if assigned_users.present?
      agents.where.not(id: assigned_users).update_all(messenger_unread: false)
    end
  end

  task update_instagram_unread: :environment do
    retailer_ids = FacebookRetailer.where(instagram_integrated: true).pluck(:retailer_id)
    Retailer.where(id: retailer_ids).find_each do |retailer|
      admins_supervisors = retailer.admins.or(retailer.supervisors)
      admins_supervisors.update_all(instagram_unread: retailer.customers.instagram
        .with_unread_messages.exists?)

      retailer.retailer_users.active_agents.only_assigned_customers
        .joins('INNER JOIN agent_customers ac ON ac.retailer_user_id = retailer_users.id')
        .joins('INNER JOIN customers c ON ac.customer_id = c.id')
        .where('c.pstype = 1 AND c.count_unread_messages > 0 AND c.retailer_id = ?', retailer.id)
        .update_all(instagram_unread: true)

      agents = retailer.retailer_users.active_agents.all_customers

      customer_ids = Customer.joins('LEFT JOIN agent_customers ac ON ac.customer_id = customers.id')
        .where('(ac.retailer_user_id IN (?) OR ac.retailer_user_id is NULL) AND customers.retailer_id = ? AND ' \
        'customers.pstype = 1 AND customers.count_unread_messages > 0',
        agents.ids, retailer.id).select('distinct customers.id')

      assigned = AgentCustomer.where(customer_id: customer_ids)
      if assigned.select('distinct customer_id').size != customer_ids.size
        agents.update_all(instagram_unread: true)
        next
      end

      assigned_users = assigned.pluck(:retailer_user_id).uniq
      agents.where(id: assigned_users).update_all(instagram_unread: true) if assigned_users.present?
      agents.where.not(id: assigned_users).update_all(instagram_unread: false)
    end
  end

  task update_ml_unread: :environment do
    retailer_ids = MeliRetailer.pluck(:retailer_id)
    Retailer.where(id: retailer_ids).find_each do |retailer|
      retailer.sync_ml_unread
    end
  end
end
