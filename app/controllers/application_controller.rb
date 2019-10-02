class ApplicationController < ActionController::Base
  layout :layout_by_resource

  before_action :set_raven_context

  private

    def layout_by_resource
      if devise_controller?
        'devise'
      else
        'application'
      end
    end

    def set_raven_context
      Raven.user_context(id: session[:current_retailer]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
end
