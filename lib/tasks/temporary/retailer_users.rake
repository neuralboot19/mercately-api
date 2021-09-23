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
    RetailerUser.joins(retailer: :customers)
      .where('retailer_users.retailer_admin = TRUE OR retailer_users.retailer_supervisor = TRUE')
      .update_all(update_admins_sql)

    # Asignados y no asignados con chats asignados
    update_non_assigned_sql = <<-SQL
      unread_whatsapp_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.ws_active = TRUE
        AND customers.count_unread_messages > 0
      ) + (
        SELECT COUNT(DISTINCT agent_customers.id)
        FROM agent_customers
        WHERE agent_customers.retailer_user_id IS NULL
        AND agent_customers.customer_id IN (
          SELECT id FROM customers
          WHERE customers.retailer_id = retailer_users.retailer_id
          AND customers.ws_active = TRUE
          AND customers.count_unread_messages > 0
        )
      )
    SQL
    RetailerUser.joins(:a_customers, retailer: { customers: :agent_customer })
      .all_customers
      .where(retailer_admin: false, retailer_supervisor: false)
      .update_all(update_non_assigned_sql)

    # Asignados y no asignados sin chats asignados
    update_non_assigned_sql = <<-SQL
      unread_whatsapp_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        LEFT JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.ws_active = TRUE
        AND customers.count_unread_messages > 0
        AND (agent_customers.id IS NULL OR agent_customers.retailer_user_id IS NULL )
      )
    SQL
    RetailerUser.joins(retailer: { customers: :agent_customer })
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
        AND customers.ws_active = TRUE AND customers.count_unread_messages > 0
      )
    SQL
    RetailerUser.joins(:a_customers)
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
    RetailerUser.joins(retailer: :customers)
      .where('retailer_users.retailer_admin = TRUE OR retailer_users.retailer_supervisor = TRUE')
      .update_all(update_admins_sql)

    # Asignados y no asignados con chats asignados
    update_non_assigned_sql = <<-SQL
      unread_messenger_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 0
        AND customers.count_unread_messages > 0
      ) + (
        SELECT COUNT(DISTINCT agent_customers.id)
        FROM agent_customers
        WHERE agent_customers.retailer_user_id IS NULL
        AND agent_customers.customer_id IN (
          SELECT id FROM customers
          WHERE customers.retailer_id = retailer_users.retailer_id
          AND customers.pstype = 0
          AND customers.count_unread_messages > 0
        )
      )
    SQL
    RetailerUser.joins(:a_customers, retailer: { customers: :agent_customer })
      .all_customers
      .where(retailer_admin: false, retailer_supervisor: false)
      .update_all(update_non_assigned_sql)

    # Asignados y no asignados sin chats asignados
    update_non_assigned_sql = <<-SQL
      unread_messenger_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        LEFT JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 0
        AND customers.count_unread_messages > 0
        AND (agent_customers.id IS NULL OR agent_customers.retailer_user_id IS NULL )
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
    RetailerUser.joins(:a_customers)
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
    RetailerUser.joins(retailer: :customers)
      .where('retailer_users.retailer_admin = TRUE OR retailer_users.retailer_supervisor = TRUE')
      .update_all(update_admins_sql)

    # Asignados y no asignados con chats asignados
    update_non_assigned_sql = <<-SQL
      unread_instagram_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 1
        AND customers.count_unread_messages > 0
      ) + (
        SELECT COUNT(DISTINCT agent_customers.id)
        FROM agent_customers
        WHERE agent_customers.retailer_user_id IS NULL
        AND agent_customers.customer_id IN (
          SELECT id FROM customers
          WHERE customers.retailer_id = retailer_users.retailer_id
          AND customers.pstype = 1
          AND customers.count_unread_messages > 0
        )
      )
    SQL
    RetailerUser.joins(:a_customers, retailer: { customers: :agent_customer })
      .all_customers
      .where(retailer_admin: false, retailer_supervisor: false)
      .update_all(update_non_assigned_sql)

    # Asignados y no asignados sin chats asignados
    update_non_assigned_sql = <<-SQL
      unread_instagram_chats_count = (
        SELECT COUNT(DISTINCT customers.id)
        FROM customers
        LEFT JOIN agent_customers ON agent_customers.customer_id = customers.id
        WHERE customers.retailer_id = retailer_users.retailer_id
        AND customers.pstype = 1
        AND customers.count_unread_messages > 0
        AND (agent_customers.id IS NULL OR agent_customers.retailer_user_id IS NULL )
      )
    SQL
    RetailerUser.joins(retailer: { customers: :agent_customer })
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
    RetailerUser.joins(:a_customers)
      .only_assigned_customers
      .update_all(update_only_assigned_sql)
  end
end
