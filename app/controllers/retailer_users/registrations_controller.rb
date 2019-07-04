# frozen_string_literal: true

class RetailerUsers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: :create
  before_action :set_locale

  def new
    @retailer_name = params[:name] || ''
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

    def set_locale
      I18n.locale = :es
    end
end
