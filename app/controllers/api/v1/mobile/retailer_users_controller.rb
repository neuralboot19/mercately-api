class Api::V1::Mobile::RetailerUsersController < Api::MobileController
  before_action :set_retailer

  def set_app_version
    if params[:app_version]
      @user.update(app_version: params[:app_version])
      render status: 200, json: {}
    else
      render status: 403, json: { error: 'App version no enviada' }
    end
  end

  private

    def set_retailer
      @user = RetailerUser.find_by_email(request.headers['email'] || create_params[:email])
      return record_not_found unless @user

      @retailer = @user.retailer
      @user
    end
end
