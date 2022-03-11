module AgentAssignmentConcern
  extend ActiveSupport::Concern

  private

    def assign_agent
      return unless retailer.payment_plan.advanced? && direction == 'inbound'
      return if customer.agent_customer

      insert_on_agent_queue
    end

    def insert_on_agent_queue
      team = retailer.team_assignments.find_by(active_assignment: true, default_assignment: true, whatsapp: true)
      return unless team

      team.with_lock do
        agents = team.agent_teams.active_ones.order(id: :asc)
        return unless agents

        agent_ids = agents.ids
        pos = agent_ids.index { |a| a > team.last_assigned.to_i }
        at = agents[pos.to_i]

        if AgentCustomer.create_with(
            retailer_user_id: at.retailer_user_id,
            team_assignment_id: team.id
          ).find_or_create_by(customer_id: customer.id)

          at.update(assigned_amount: at.assigned_amount + 1) unless customer.resolved?
          team.update_column(:last_assigned, at.id)
        end
      end
    end
end
