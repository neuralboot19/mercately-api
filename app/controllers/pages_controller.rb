class PagesController < ApplicationController
  def index
    if current_retailer
      redirect_to retailers_dashboard_path(current_retailer)
    end
  end
end
