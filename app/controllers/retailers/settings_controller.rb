class Retailers::SettingsController < RetailersController
  
  def team
    @team = current_retailer.retailer_users.reject { |u| u == current_retailer_user }
    @user = RetailerUser.new
  end

  def invite_team_member
    user = RetailerUser.invite!(email: params['retailer_user']['email'], retailer_admin:
      false, retailer: current_retailer) do |u|
      u.skip_invitation = true
    end

    if user&.persisted?
      user.update_column(:invitation_sent_at, Time.now.utc) if RetailerMailer.invitation(user).deliver_now

      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario invitado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al invitar usuario.'
    end
  end

  def reinvite_team_member
    user = RetailerUser.find(params['user'])
    if user
      user.invite! do |u|
        u.skip_invitation = true
      end

      user.update_column(:invitation_sent_at, Time.now.utc) if RetailerMailer.invitation(user).deliver_now

      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario invitado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al invitar usuario.'
    end
  end

  def remove_team_member
    user = RetailerUser.find(params['user'])
    if user.update_column(:removed_from_team, true)
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario removido con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al remover usuario.'
    end
  end

  def reactive_team_member
    user = RetailerUser.find(params['user'])
    if user.update_column(:removed_from_team, false)
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Usuario reactivado con éxito.'
    else
      redirect_back fallback_location: retailers_dashboard_path(@retailer),
                    notice: 'Error al reactivar usuario.'
    end
  end

  def api_key
  end

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
end
