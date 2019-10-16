class RetailerUsers::RegistrationsController < Devise::RegistrationsController
  include CurrentRetailer
  layout 'dashboard', only: %i[edit update]

  before_action :configure_sign_up_params, only: :create
  before_action :check_passwords, only: :update
  before_action :configure_account_update_params, only: :update
  before_action :set_locale
  skip_before_action :set_retailer, except: %i[edit update]

  def edit
  end

  def new
    @retailer_name = params[:name] || ''
    super
  end

  def update
    changed_password = params[:retailer_user][:password].present?

    is_valid = if changed_password
                 current_retailer_user.update_with_password(account_update_params)
               else
                 current_retailer_user.update_without_password(account_update_params)
               end

    if is_valid
      set_flash_message :notice, :updated
      bypass_sign_in(current_retailer_user) if changed_password
      redirect_to after_update_path_for(current_retailer_user)
    else
      render :edit
    end
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

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [
                                          :email,
                                          :password,
                                          :password_confirmation,
                                          retailer_attributes: [:id, :name]
                                        ])
    end

    def set_locale
      I18n.locale = :es
    end

    def check_passwords
      return unless params[:retailer_user][:password].blank? &&
                    params[:retailer_user][:password_confirmation].blank?

      params[:retailer_user].delete(:password)
      params[:retailer_user].delete(:password_confirmation)
      params[:retailer_user].delete(:current_password)
    end

    def after_sign_up_path_for(_resource)
      retailers_integrations_path(current_retailer_user.retailer, onboarding: true)
    end
end
