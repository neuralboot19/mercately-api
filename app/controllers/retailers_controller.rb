class RetailersController < ApplicationController
  before_action :authenticate_retailer!
  def dashboard
  end
end
