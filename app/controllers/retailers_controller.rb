class RetailersController < ApplicationController
  before_action :authenticate_retailer_user!

  def dashboard
  end
end
