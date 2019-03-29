class RetailersController < ApplicationController
  layout 'dashboard'
  before_action :authenticate_retailer_user!
  before_action :set_retailer
  helper_method :current_retailer

  def current_retailer
    @retailer
  end

  private

    def set_retailer
      unless session[:current_retailer]
        @retailer = Retailer.find_by(slug: params[:slug])
        session[:current_retailer] = @retailer
      else
        @retailer = Retailer.find(session[:current_retailer]['id'])
      end
      redirect_to root_path unless @retailer
end
