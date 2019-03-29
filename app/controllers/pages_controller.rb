class PagesController < ApplicationController
  def index
    redirect_to retailers_dashboard_path(current_retailer) if current_retailer
  end
end
