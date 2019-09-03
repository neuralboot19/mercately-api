class PagesController < ApplicationController
  def index
    redirect_to retailers_dashboard_path(current_retailer_user.retailer) if current_retailer_user
  end

  def privacy
  end

  def terms
  end
end
