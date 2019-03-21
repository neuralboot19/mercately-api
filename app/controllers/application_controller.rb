class ApplicationController < ActionController::Base
  before_action :set_raven_context
  helper_method :current_retailer

  def current_retailer
    current_retailer_user.retailer
  end

  private

    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
end
