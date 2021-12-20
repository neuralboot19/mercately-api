module CurrentRetailer
  extend ActiveSupport::Concern

  included do
    before_action :set_retailer
    helper_method :current_retailer
    before_action :check_notifications
  end

  def current_retailer
    @retailer
  end

  protected

    def set_retailer
      @retailer = current_retailer_user&.retailer

      session[:current_retailer] = @retailer if session[:current_retailer].blank?
    end

    def check_notifications
      @notifications = current_retailer_user.agent_notifications.eager_load(:customer).order(created_at: :desc).page(1) if current_retailer_user
    end
end
