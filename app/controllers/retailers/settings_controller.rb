class Retailers::SettingsController < RetailersController
  before_action :set_user, only: [:set_admin_team_member, :set_agent_team_member,
                                  :set_supervisor_team_member, :reinvite_team_member,
                                  :remove_team_member, :reactive_team_member, :update]

  def team
    if current_retailer_user.agent?
      redirect_to root_path
      return
    end

    @team = current_retailer.retailer_users.order(:id)
    @team = @team.reject { |u| u == current_retailer_user } unless current_retailer_user == @team.first
    @user = RetailerUser.new
  end

  def update
    if @user.update(invitation_params)
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario actualizado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al actualizar usuario.'
    end
  end

  def invite_team_member
    user = RetailerUser.invite!(
      first_name: invitation_params[:first_name],
      last_name: invitation_params[:last_name],
      email: invitation_params[:email],
      retailer_admin: invitation_params[:retailer_admin] || false,
      retailer_supervisor: invitation_params[:retailer_supervisor] || false,
      only_assigned: invitation_params[:only_assigned] || false,
      retailer: current_retailer) do |u|
      u.skip_invitation = true
    end

    if user&.errors.present?
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: user.errors.full_messages.join(', ')
    elsif user&.persisted?
      user.update_column(:invitation_sent_at, Time.now.utc) if RetailerMailer.invitation(user).deliver_now

      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario invitado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al invitar usuario.'
    end
  end

  def set_admin_team_member
    if @user.update_columns(
      retailer_admin: true,
      retailer_supervisor: false,
    )
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario actualizado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al actualizar usuario.'
    end
  end

  def set_agent_team_member
    if @user.update_columns(
      retailer_admin: false,
      retailer_supervisor: false
    )
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario actualizado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al actualizar usuario.'
    end
  end

  def set_supervisor_team_member
    if @user.update_columns(
      retailer_admin: false,
      retailer_supervisor: true
    )
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario actualizado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al actualizar usuario.'
    end
  end

  def reinvite_team_member
    if @user
      @user.invite! do |u|
        u.skip_invitation = true
      end

      @user.update_column(:invitation_sent_at, Time.now.utc) if RetailerMailer.invitation(@user).deliver_now

      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario invitado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al invitar usuario.'
    end
  end

  def remove_team_member
    if @user.update_column(:removed_from_team, true)
      @user.agent_teams.update_all(active: false)
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario removido con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al remover usuario.'
    end
  end

  def reactive_team_member
    if @user.update_attribute(:removed_from_team, false)
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario reactivado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: @user.errors.full_messages.join(', ')
    end
  end

  def api_key; end

  def generate_api_key
    api_key =  @retailer.generate_api_key
    respond_to do |format|
      format.json {
        render status: 200, json: { message: '¡API Key generada!', info: {
          data: { id: @retailer.id, type: 'retailer', attributes: {
            api_key: api_key
          }}
        }}
      }
    end
  end

  private

  def set_user
    @user = RetailerUser.find_by_id(params['user'])
  end

  def invitation_params
    params.require(:retailer_user)
          .permit(
            :email,
            :first_name,
            :last_name,
            :role,
            :only_assigned
          ).tap do |param|
            if param[:role].present?
              role = param.delete(:role)
              param[role.to_sym] = true
            end
          end
  end
end
