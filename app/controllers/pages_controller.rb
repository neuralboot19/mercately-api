class PagesController < ApplicationController
  layout 'catalog', only: [:catalog, :product]

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

  def chatbots_whatsapp
  end

  def catalog
    @products = @retailer.products
  end

  def product
    @product = @retailer.products.find_by_web_id(params[:web_id])
  end

  def go_to_wp
    redirect_to "https://api.whatsapp.com/send?l=es&phone=12393231403&text=#{params['text']}"
  end

  def request_demo
    recaptcha_valid = if params['g-recaptcha-response']&.[]('schedule')
                        verify_recaptcha(action: 'schedule')
                      else
                        verify_recaptcha(secret_key: ENV['RECAPTCHA_SECRET_KEY_V2'])
                      end
    if recaptcha_valid
      demo_request_lead = DemoRequestLead.create(
        name: params[:name],
        email: params[:email],
        company: params[:company],
        employee_quantity: params[:employee_quantity],
        country: params[:country].is_a?(Array) ? params[:country][0] : params[:country],
        phone: params[:phone],
        message: params[:message],
        problem_to_resolve: params[:problem_to_resolve]
      )

      RequestDemoMailer.demo_requested(demo_request_lead).deliver_now if demo_request_lead.persisted?

      if params['from-ws-crm'].present?
        redirect_to whatsapp_crm_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
      else
        redirect_to root_path, notice: 'Gracias! Nuestro equipo se contactará pronto.'
      end
    else
      @show_checkbox_recaptcha = true

      if params['from-ws-crm'].present?
        redirect_to whatsapp_crm_path, notice: 'El reCAPTCHA ha fallado, por favor intenta de nuevo'
      else
        redirect_to root_path, notice: 'El reCAPTCHA ha fallado, por favor intenta de nuevo'
      end
    end
  end

  private

    def set_retailer
      @retailer = Retailer.find_by_slug(params[:slug]) || not_found
    end
end
