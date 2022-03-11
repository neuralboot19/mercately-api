class Retailers::AgentTeamsController < RetailersController
  def create
    @agent_team = AgentTeam.new(agent_team_params)

    notice = if @agent_team.save
               'Asignación creada con éxito.'
             else
               @agent_team.errors.full_messages
             end
    redirect_to retailers_team_assignments_path(current_retailer), notice: notice
  end

  def update_assignments
    @agent = current_retailer.retailer_users.find(params[:id])
    notice = if @agent.update(retailer_user_params)
               'Asignación actualizada con éxito.'
             else
               @agent.errors.full_messages
             end
    redirect_to retailers_team_assignments_path(current_retailer), notice: notice
  end

  private

    def agent_team_params
      params.require(:agent_team).permit(
        :retailer_user_id,
        :team_assignment_id,
        :active
      )
    end

    def retailer_user_params
      params.require(:retailer_user).permit(
        agent_teams_attributes: [
          :id,
          :active,
          :_destroy
        ]
      )
    end
end
