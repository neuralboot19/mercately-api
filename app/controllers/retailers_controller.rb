class RetailersController < ApplicationController
  include CurrentRetailer
  layout 'dashboard'
  before_action :authenticate_retailer_user!
  before_action :validate_payment_plan

  private

    def validate_payment_plan
      return if controller_name == 'payment_plans'
      return if current_retailer.payment_plan.is_active?
      redirect_to(retailers_payment_plans_path(current_retailer)) && return
    end
end
