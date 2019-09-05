class RetailersController < ApplicationController
  include CurrentRetailer
  layout 'dashboard'
  before_action :authenticate_retailer_user!
end
