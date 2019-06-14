# frozen_string_literal: true

class RetailerUsers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @new_retailer = {}
    super
  end

  # POST /resource
  def create
    @new_retailer = params['retailer_user']
    super
  end

  protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [
                                          :email,
                                          :password,
                                          :password_confirmation,
                                          :agree_terms,
                                          retailer_attributes: :name
                                        ])
    end
end
