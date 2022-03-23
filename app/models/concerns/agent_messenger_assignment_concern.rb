module AgentMessengerAssignmentConcern
  extend ActiveSupport::Concern

  private

    def assign_agent
      # Se le asigna el agente al customer si no tiene uno ya asignado.
      # Solo cuando el mensaje es enviado por un agente/admin/supervisor.
      if retailer_user
        AgentCustomer.create_with(retailer_user: retailer_user).find_or_create_by(customer: customer)
      end
      return unless facebook_retailer.retailer.payment_plan.advanced? && sent_by_retailer == false
      return if customer.agent_customer

      insert_on_agent_queue
    end

    def insert_on_agent_queue
      team_platform = self.class == FacebookMessage ? 'messenger' : 'instagram'
      team = facebook_retailer.retailer.team_assignments.find_by(
        active_assignment: true,
        default_assignment: true,
        team_platform => true
      )
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
        end
      end
    end
end
