module AgentMessengerAssignmentConcern
  extend ActiveSupport::Concern

  private

    def assign_agent
      # Se le asigna el agente al customer si no tiene uno ya asignado.
      # Solo cuando el mensaje es enviado por un agente/admin/supervisor.
      AgentCustomer.create_with(retailer_user: retailer_user).find_or_create_by(customer: customer) if retailer_user
        .present?
      return unless facebook_retailer.retailer.manage_team_assignment

      if sent_by_retailer == false
        return if customer.agent_customer || customer.messenger_answered_by_agent?

        insert_on_agent_queue
      elsif sent_by_retailer == true
        return unless retailer_user && customer.agent_customer&.team_assignment &&
                      customer.first_messenger_answer_by_agent?(mid)

        remove_from_agent_queue
      end
    end

    def insert_on_agent_queue
      team = facebook_retailer.retailer.team_assignments.where(active_assignment: true, default_assignment: true).first
      return unless team

      agent_teams = team.agent_teams.active_ones.order(:assigned_amount)
      agent_teams.each do |at|
        next if at.free_spots_assignment <= 0

        if AgentCustomer.create_with(retailer_user_id: at.retailer_user_id, team_assignment_id: team.id)
                        .find_or_create_by(customer_id: customer.id)

          at.update(assigned_amount: at.assigned_amount + 1)
          return
        end
      end
    end

    def remove_from_agent_queue
      agent_customer = customer.agent_customer
      agent_team = AgentTeam.where(retailer_user_id: agent_customer.retailer_user_id,
        team_assignment_id: agent_customer.team_assignment_id).first
      return unless agent_team

      agent_team.update(assigned_amount: agent_team.assigned_amount - 1)
    end
end
