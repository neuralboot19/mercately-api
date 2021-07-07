class ApplicationController < ActionController::Base
  layout :layout_by_resource
  before_action :set_raven_context
  around_action :switch_locale
  skip_before_action :track_ahoy_visit

  def switch_locale(&action)
    locale = current_retailer_user.try(:locale) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def current_subdomain
    Retailer.find_by_slug(request.subdomain).present?
  end

  private

    def not_found
      redirect_to(root_path) && return
    end

    def layout_by_resource
      if devise_controller?
        'devise'
      else
        'application'
      end
    end

    def set_raven_context
      Raven.user_context(id: session[:current_retailer]&.[]('id'), retailer: session[:current_retailer]&.[]('name'))
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end

    def ensure_subdomain
      redirect_to root_url(subdomain: request.subdomain) unless current_subdomain
    end
end
