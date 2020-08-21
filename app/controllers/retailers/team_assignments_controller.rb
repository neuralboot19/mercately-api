class Retailers::TeamAssignmentsController < RetailersController
  before_action :check_assignment_access
  before_action :check_ownership, except: [:index, :new, :create]
  before_action :set_team_assignment, except: [:index, :new, :create]

  def index
    @team_assignments = current_retailer.team_assignments.page(params[:page])
  end

  def new
    @team_assignment = TeamAssignment.new
  end

  def create
    @team_assignment = current_retailer.team_assignments.new(team_assignment_params)

    if @team_assignment.save
      redirect_to retailers_team_assignment_path(current_retailer, @team_assignment), notice:
        'Equipo creado con éxito.'
    else
      render :new
    end
  end

  def update
    if @team_assignment.update(team_assignment_params)
      redirect_to retailers_team_assignment_path(current_retailer, @team_assignment), notice:
        'Equipo actualizado con éxito.'
    else
      render :edit
    end
  end

  def destroy
    if @team_assignment.destroy
      redirect_to retailers_team_assignments_path(current_retailer), notice:
        'Equipo eliminado con éxito.'
    else
      redirect_to retailers_team_assignments_path(current_retailer), notice:
        @team_assignment.errors['base'].join(', ')
    end
  end

  private

    def check_ownership
      team_assignment = current_retailer.team_assignments.find_by_web_id(params[:id])
      redirect_to retailers_dashboard_path(current_retailer), notice:
        'No posees los permisos para acceder a la dirección ingresada.' unless team_assignment
    end

    def set_team_assignment
      @team_assignment = TeamAssignment.find_by_web_id(params[:id])
    end

    def check_assignment_access
      redirect_to retailers_dashboard_path(current_retailer) unless current_retailer.manage_team_assignment
    end

    def team_assignment_params
      params.require(:team_assignment).permit(
        :name,
        :active_assignment,
        :default_assignment,
        agent_teams_attributes: [
          :id,
          :retailer_user_id,
          :max_assignments,
          :active,
          :_destroy
        ]
      )
    end
end
