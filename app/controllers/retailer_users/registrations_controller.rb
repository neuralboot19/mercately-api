# frozen_string_literal: true

class RetailerUsers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @new_retailer = {}
    @new_retailer['name'] = params['name']
    super
  end

  # POST /resource
  def create
    @new_retailer ||= {}
    @new_retailer['name'] = params['retailer_user']['retailer_attributes']['name'] if params['retailer_user']['retailer_attributes'].present?
    @new_retailer['email'] = params['retailer_user']['email'].presence
    @new_retailer['password'] = params['retailer_user']['password'].presence
    @new_retailer['password_confirmation'] = params['retailer_user']['password_confirmation'].presence
    @new_retailer['agree_terms'] = params['retailer_user']['agree_terms'].presence
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
