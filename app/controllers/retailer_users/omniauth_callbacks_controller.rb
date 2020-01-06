class RetailerUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def facebook
    # TODO: validar que el usuario no selecciono mas de una pagina
    auth = request.env['omniauth.auth']
    granted_permissions = Facebook::Api.validate_granted_permissions(auth.credentials.token)
    redirect_to retailer_user_facebook_omniauth_authorize_path && return unless granted_permissions

    @retailer_user = RetailerUser.from_omniauth(auth, current_retailer_user)

    if @retailer_user.persisted?
      sign_in_and_redirect @retailer_user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_retailer_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
