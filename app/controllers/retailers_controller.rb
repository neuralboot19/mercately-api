class RetailersController < ApplicationController
  before_action :authenticate_retailer_user!
  before_action :set_retailer

  private

    def set_retailer
      @retailer = Retailer.find_by(slug: params[:slug])
      redirect_to root_path unless @retailer
    end
end
