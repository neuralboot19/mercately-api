class RetailersController < ApplicationController
  before_action :authenticate_retailer_user!
  before_action :set_retailer

  def dashboard
  end

  private

    def set_retailer
      @retailer = Retailer.find_by(slug: params[:slug])
    end
end
