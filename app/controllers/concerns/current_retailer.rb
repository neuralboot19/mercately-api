module CurrentRetailer
  extend ActiveSupport::Concern

  included do
    before_action :set_retailer
    helper_method :current_retailer
  end

  def current_retailer
    @retailer
  end

  protected

    def set_retailer
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
end
