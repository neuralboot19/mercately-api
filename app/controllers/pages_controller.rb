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
    recaptcha_valid = if params['g-recaptcha-response']&.[]('schedule')
                        verify_recaptcha(action: 'schedule')
                      else
                        verify_recaptcha(secret_key: ENV['RECAPTCHA_SECRET_KEY_V2'])
                      end
    if recaptcha_valid
      RequestDemoMailer.demo_requested(params.to_unsafe_h).deliver_now
      redirect_to root_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
    else
      @show_checkbox_recaptcha = true
      render :index, notice: 'El reCAPTCHA ha fallado, por favor intenta de nuevo'
    end
  end
end
