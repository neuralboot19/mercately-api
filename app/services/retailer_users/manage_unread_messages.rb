module RetailerUsers
  class ManageUnreadMessages
    def initialize(customer, retailer)
      @customer = customer
      @retailer = retailer
    end

    def mark_unread_flag
      return unless @customer.count_unread_messages > 0

      @customer.update_column(:count_unread_messages, 0)

      admins_supervisors = @retailer.admins.or(@retailer.supervisors)
      admins_supervisors.update_all(whatsapp_unread: @retailer.customers.active_whatsapp
        .with_unread_messages.exists?)

      agent = @customer.agent
      return if agent && !agent.agent?

      if agent.present?
        if agent.only_assigned?
          agent.update_column(:whatsapp_unread, agent.a_customers.active_whatsapp.with_unread_messages.exists?)
        else
          agent.update_column(:whatsapp_unread, agent.customers.active_whatsapp.with_unread_messages.exists?)
        end
      else
        agents = @retailer.retailer_users.active_agents.all_customers

        customer_ids = Customer.joins('LEFT JOIN agent_customers ac ON ac.customer_id = customers.id')
          .where('(ac.retailer_user_id IN (?) OR ac.retailer_user_id is NULL) AND customers.retailer_id = ? AND ' \
          'customers.ws_active = ? AND customers.count_unread_messages > 0',
          agents.ids, @retailer.id, true).select('distinct customers.id')

        assigned = AgentCustomer.where(customer_id: customer_ids)
        if assigned.select('distinct customer_id').size != customer_ids.size
          agents.update_all(whatsapp_unread: true)
          return
        end

        assigned_users = assigned.pluck(:retailer_user_id).uniq
        agents.where(id: assigned_users).update_all(whatsapp_unread: true) if assigned_users.present?
        agents.where.not(id: assigned_users).update_all(whatsapp_unread: false)
      end
    end
  end
end
