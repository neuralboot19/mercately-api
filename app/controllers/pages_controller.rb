class PagesController < ApplicationController
  def index
    redirect_to retailers_orders_path(current_retailer_user.retailer, status: 'all') if current_retailer_user
  end

  def privacy
  end

  def terms
  end
end
