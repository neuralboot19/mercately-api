class RetailerUsersController < ApplicationController
  before_action :authenticate_retailer_user!

  def update_onboarding_info
    onboarding_status = onboarding_status_params.to_h
    if current_retailer_user.update(onboarding_status: onboarding_status)
      render json: {}, status: :ok
    else
      render json: {}, status: 500
    end
  end

  def onboarding_status_params
    params.require(:onboarding_status).permit(:step, :skipped, :completed)
  end
end
