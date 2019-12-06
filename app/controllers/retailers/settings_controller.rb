class Retailers::SettingsController < RetailersController
  
  def team
    @team = current_retailer.retailer_users.where(removed_from_team: false).reject { |u| u == current_retailer_user } 
    @user = RetailerUser.new
  end

  def invite_team_member
    user = RetailerUser.invite!(email: params['retailer_user']['email'], retailer_admin: false, retailer: current_retailer) do |u|
      u.skip_invitation = true
    end

    if user
      if RetailerMailer.invitation(user).deliver_now
        user.update_column(:invitation_sent_at, Time.now.utc)
      end

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

      if RetailerMailer.invitation(user).deliver_now
        user.update_column(:invitation_sent_at, Time.now.utc)
      end

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
end
