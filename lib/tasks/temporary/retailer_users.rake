namespace :retailer_users do
  task update_unread_whatsapp_chats_count: :environment do
    # Admins y supervisores
    update_admins_sql = <<-SQL
      unread_whatsapp_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.ws_active = TRUE
        AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser
      .where('retailer_users.retailer_admin = TRUE OR retailer_users.retailer_supervisor = TRUE')
      .update_all(update_admins_sql)

    # Asignados y no asignados
    update_non_assigned_sql = <<-SQL
      unread_whatsapp_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        INNER JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND agent_customers.retailer_user_id = retailer_users.id
        AND customers.ws_active = TRUE
        AND customers.count_unread_messages > 0
      ) + (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        LEFT JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.ws_active = TRUE
        AND customers.count_unread_messages > 0
        AND agent_customers.customer_id IS NULL
      )
    SQL
    RetailerUser
      .all_customers
      .where(retailer_admin: false, retailer_supervisor: false)
      .update_all(update_non_assigned_sql)

    # Solo asignados
    update_only_assigned_sql = <<-SQL
      unread_whatsapp_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        INNER JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND agent_customers.retailer_user_id = retailer_users.id
        AND customers.ws_active = TRUE
        AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser
      .only_assigned_customers
      .update_all(update_only_assigned_sql)
  end

  task update_unread_messenger_chats_count: :environment do
    # Admins y supervisores
    update_admins_sql = <<-SQL
      unread_messenger_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 0
        AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser
      .where('retailer_users.retailer_admin = TRUE OR retailer_users.retailer_supervisor = TRUE')
      .update_all(update_admins_sql)

    # Asignados y no asignados
    update_non_assigned_sql = <<-SQL
      unread_messenger_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        INNER JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND agent_customers.retailer_user_id = retailer_users.id
        AND customers.pstype = 0
        AND customers.count_unread_messages > 0
      ) + (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        LEFT JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 0
        AND customers.count_unread_messages > 0
        AND agent_customers.customer_id IS NULL
      )
    SQL
    RetailerUser
      .all_customers
      .where(retailer_admin: false, retailer_supervisor: false)
      .update_all(update_non_assigned_sql)

    # Solo asignados
    update_only_assigned_sql = <<-SQL
      unread_messenger_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        INNER JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND agent_customers.retailer_user_id = retailer_users.id
        AND customers.pstype = 0
        AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser
      .only_assigned_customers
      .update_all(update_only_assigned_sql)
  end

  task update_unread_instagram_chats_count: :environment do
    # Admins y supervisores
    update_admins_sql = <<-SQL
      unread_instagram_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 1
        AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser
      .where('retailer_users.retailer_admin = TRUE OR retailer_users.retailer_supervisor = TRUE')
      .update_all(update_admins_sql)

    # Asignados y no asignados
    update_non_assigned_sql = <<-SQL
      unread_messenger_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        INNER JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND agent_customers.retailer_user_id = retailer_users.id
        AND customers.pstype = 1
        AND customers.count_unread_messages > 0
      ) + (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        LEFT JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 1
        AND customers.count_unread_messages > 0
        AND agent_customers.customer_id IS NULL
      )
    SQL
    RetailerUser
      .all_customers
      .where(retailer_admin: false, retailer_supervisor: false)
      .update_all(update_non_assigned_sql)

    # Solo asignados
    update_only_assigned_sql = <<-SQL
      unread_instagram_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        INNER JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND agent_customers.retailer_user_id = retailer_users.id
        AND customers.pstype = 1
        AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser
      .only_assigned_customers
      .update_all(update_only_assigned_sql)
  end

  task update_unread_ml_count: :environment do
    RetailerUser.update_all(
      <<-SQL
        unread_ml_questions_count = (
          SELECT COUNT(DISTINCT questions.id)
          FROM questions
          INNER JOIN customers ON customers.id = questions.customer_id
          WHERE (questions.product_id IS NOT NULL)
          AND questions.date_read IS NULL
          AND customers.retailer_id = retailer_users.retailer_id
        ),
        unread_ml_chats_count = (
          SELECT COUNT(DISTINCT orders.id)
          FROM orders
          INNER JOIN customers ON customers.id = orders.customer_id
          WHERE orders.count_unread_messages > 0
          AND customers.retailer_id = retailer_users.retailer_id
        )
      SQL
    )
    RetailerUser.update_all(
      <<-SQL
        total_unread_ml_count = unread_ml_questions_count + unread_ml_chats_count
      SQL
    )
    RetailerUser.where('total_unread_ml_count > 0').update_all(ml_unread: true)
  end

  task update_token_expiration: :environment do
    RetailerUser.where.not(api_session_expiration: nil)
      .where('api_session_expiration > ?', Time.now)
      .update_all(api_session_expiration: 1.year.from_now)
  end
end
