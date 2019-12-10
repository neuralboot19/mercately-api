class PagesController < ApplicationController
  def index
    return unless current_retailer_user

    redirect_to retailers_dashboard_path(current_retailer_user.retailer.slug,
                                         current_retailer_user.retailer.web_id)
  end

  def privacy
  end

  def terms
  end

  def request_demo
    RequestDemoMailer.demo_requested(params.to_unsafe_h).deliver_now
    redirect_to root_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
  end
end
