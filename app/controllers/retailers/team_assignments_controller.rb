class Retailers::TeamAssignmentsController < RetailersController
  before_action :set_team_assignment, except: [:index, :new, :create]
  layout 'chats/chat', only: :index

  def index
    @teams = current_retailer.team_assignments.order(:name).page(params[:page])
    @team_assignment = TeamAssignment.new(retailer: current_retailer)
    @agent_team = AgentTeam.new
  end

  def new
    @team_assignment = TeamAssignment.new
  end

  def create
    @team_assignment = current_retailer.team_assignments.new(team_assignment_params)

    if @team_assignment.save
      redirect_to retailers_team_assignments_path(current_retailer), notice: 'Equipo creado con éxito.'
    else
      redirect_to retailers_team_assignments_path(current_retailer), notice: @team_assignment.errors['base'].join(', ')
    end
  end

  def update
    if @team_assignment.update(team_assignment_params)
      redirect_to retailers_team_assignments_path(current_retailer), notice: 'Equipo actualizado con éxito.'
    else
      redirect_to retailers_team_assignments_path(current_retailer), notice: @team_assignment.errors['base'].join(', ')
    end
  end

  def destroy
    if @team_assignment.destroy
      redirect_to retailers_team_assignments_path(current_retailer), notice: 'Equipo eliminado con éxito.'
    else
      redirect_to retailers_team_assignments_path(current_retailer), notice: @team_assignment.errors['base'].join(', ')
    end
  end

  private

    def set_team_assignment
      @team_assignment = current_retailer.team_assignments.find_by_web_id!(params[:id])
    end

    def team_assignment_params
      params.require(:team_assignment).permit(
        :name,
        :active_assignment,
        :default_assignment,
        :whatsapp,
        :messenger,
        :instagram,
        agent_teams_attributes: [
          :id,
          :retailer_user_id,
          :active,
          :_destroy
        ]
      )
    end
end
