class RetailersController < ApplicationController
  before_action :authenticate_retailer_user!
  before_action :current_retailer

  private

    def current_retailer
      unless session[:current_retailer]
        @retailer = Retailer.find_by(slug: params[:slug])
        session[:current_retailer] = @retailer
      else
        @retailer = Retailer.find(session[:current_retailer]['id'])
      end
      redirect_to root_path unless @retailer
    end
end
