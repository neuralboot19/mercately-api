class RetailerUsers::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [:email, :password, :password_confirmation,
                                                                   :agree_terms, :invitation_token])
    end
end
