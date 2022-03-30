namespace :not_important_retailer_users do
=begin
- GiftCloset 845
- Kayum 699
- Immaka 595
- Alimesa 741
- Fajas la silueta 899
- ShopiLove 857
- Cencasit 886
- FastFarma Ecuador 1109
=end
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
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
      .joins(retailer: :payment_plan)
      .where(payment_plans: { status: 0 })
      .where(removed_from_team: false)
      .where.not(retailer_id: [845, 699, 595, 741, 899, 857, 886, 1109])
      .only_assigned_customers
      .update_all(update_only_assigned_sql)
  end
end
