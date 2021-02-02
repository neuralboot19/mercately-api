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
      @retailer = @current_retailer and return if @current_retailer

      unless session[:current_retailer]
        @retailer = if params[:slug].present?
          Retailer.find_by(slug: params[:slug])
        else
          current_retailer_user&.retailer
        end
        session[:current_retailer] = @retailer
      else
        Retailer.with_advisory_lock('retailers_lock') do
          @retailer = Retailer.find(session[:current_retailer]['id'])
        end
      end
    end

    def check_notifications
      @notifications = current_retailer_user.agent_notifications.order(created_at: :desc).page(1) if current_retailer_user
    end
end
