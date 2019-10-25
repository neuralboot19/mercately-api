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
        @retailer = Retailer.find_by(slug: params[:slug])
        session[:current_retailer] = @retailer
      else
        @retailer = Retailer.find(session[:current_retailer]['id'])
      end
    end
end