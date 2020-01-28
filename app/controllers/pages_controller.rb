class PagesController < ApplicationController
  def index
    redirect_to retailers_dashboard_path(current_retailer_user.retailer) if current_retailer_user
  end

  def price
  end

  def privacy
  end

  def terms
  end

  def crm
  end

  def request_demo
    RequestDemoMailer.demo_requested(params.to_unsafe_h).deliver_now
    redirect_to root_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
  end
end
