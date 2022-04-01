module AgentAssignmentConcern
  extend ActiveSupport::Concern

  private

    def assign_agent
      return if direction == 'outbound'

      if customer.agent_customer
        reassign_customer
      else
        insert_on_agent_queue
      end
    end

    def insert_on_agent_queue
      team = find_team
      return unless team

      team.with_lock do
        agents = team.agent_teams.active_ones.order(id: :asc)
        return unless agents.present?

        agent_ids = agents.ids
        pos = agent_ids.index { |a| a > team.last_assigned.to_i }
        at = agents[pos.to_i]

        if AgentCustomer.create_with(
            retailer_user_id: at.retailer_user_id,
            team_assignment_id: team.id
          ).find_or_create_by(customer_id: customer.id)

          at.update(assigned_amount: at.assigned_amount + 1) unless customer.resolved?
          team.update_column(:last_assigned, at.id)

          notification_service.notify_agents(customer, at.retailer_user)
        end
      end
    end

    def reassign_customer
      return unless retailer.has_rule?('free_chat_absent_agent')

      agent_customer = customer.agent_customer
      current_agent = agent_customer.retailer_user
      return if current_agent.active

      team = find_team

      if team
        team.with_lock do
          agents = team.agent_teams.active_ones.order(id: :asc)
          unless agents.present?
            agent_customer.destroy
            notification_service.notify_agents(customer, nil)
            return
          end

          agent_ids = agents.ids
          pos = agent_ids.index { |a| a > team.last_assigned.to_i }
          at = agents[pos.to_i]

          return unless agent_customer.update(retailer_user_id: at.retailer_user_id, team_assignment_id: team.id)

          at.update(assigned_amount: at.assigned_amount + 1) unless customer.resolved?
          team.update_column(:last_assigned, at.id)

          notification_service.notify_agents(customer, at.retailer_user, current_agent)
        end
      else
        agent_customer.destroy
        notification_service.notify_agents(customer, nil)
      end
    end

    def find_team
      return unless retailer.payment_plan.advanced?

      retailer.team_assignments.find_by(active_assignment: true, default_assignment: true, whatsapp: true)
    end

    def notification_service
      Shared::AutomaticAssignments.new
    end
end
