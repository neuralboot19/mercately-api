class RetailersController < ApplicationController
  include CurrentRetailer
  layout 'dashboard'
  before_action :authenticate_retailer_user!
  before_action :validate_payment_plan
  before_action :notification

  private

    def notification
      retailer_user_notifications = current_retailer_user
        .retailer_user_notifications
        .joins(:notification)
        .where('seen = FALSE AND (notifications.published = TRUE AND (notifications.visible_until IS NULL OR notifications.visible_until > NOW()))')
      return unless retailer_user_notifications.exists?

      @news = Notification.where(id: retailer_user_notifications.pluck(:notification_id))
      retailer_user_notifications.update_all(seen: true)
    end

    def validate_payment_plan
      return unless current_retailer
      return if controller_name == 'payment_plans'
      return if current_retailer.payment_plan.is_active?

      redirect_to(retailers_payment_plans_path(current_retailer)) && return
    end
end
