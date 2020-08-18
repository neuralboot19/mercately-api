class PagesController < ApplicationController
  layout 'catalog', only: [:catalog, :product]
  layout 'new_pages', only: [:whatsapp_crm]
  before_action :set_retailer, only: [:catalog, :product]

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

  def whatsapp_crm
    @show_checkbox_recaptcha = true
  end

  def catalog
    @products = @retailer.products
  end

  def product
    @product = @retailer.products.find_by_web_id(params[:web_id])
  end

  def request_demo
    recaptcha_valid = if params['g-recaptcha-response']&.[]('schedule')
                        verify_recaptcha(action: 'schedule')
                      else
                        verify_recaptcha(secret_key: ENV['RECAPTCHA_SECRET_KEY_V2'])
                      end
    if recaptcha_valid
      RequestDemoMailer.demo_requested(params.to_unsafe_h).deliver_now

      if params['from-ws-crm'].present?
        redirect_to whatsapp_crm_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
      else
        redirect_to root_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
      end
    else
      @show_checkbox_recaptcha = true

      if params['from-ws-crm'].present?
        render :whatsapp_crm, layout: 'new_pages', notice: 'El reCAPTCHA ha fallado, por favor intenta de nuevo'
      else
        render :index, notice: 'El reCAPTCHA ha fallado, por favor intenta de nuevo'
      end
    end
  end

  private

    def set_retailer
      @retailer = Retailer.find_by_slug(params[:slug])
    end
end
