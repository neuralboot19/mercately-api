class RetailerUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # TODO validar que el usuario no selecciono mas de una pagina
    if request.env["omniauth.auth"].info.email.blank?
      redirect_to "/users/auth/facebook?auth_type=rerequest&scope=email" and return
    end

    @retailer_user = RetailerUser.from_omniauth(request.env["omniauth.auth"])

    if @retailer_user.persisted?
      sign_in_and_redirect @retailer_user, event: :authentication
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_retailer_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
