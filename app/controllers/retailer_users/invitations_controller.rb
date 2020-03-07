class RetailerUsers::InvitationsController < Devise::InvitationsController
  include CurrentRetailer
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :after_accept, only: :update

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [:email, :password, :password_confirmation,
                                                                   :agree_terms, :invitation_token])
    end

    def after_accept
      session[:room_id] = current_retailer_user.retailer_id if current_retailer_user.invitation_accepted_at
    end
end
