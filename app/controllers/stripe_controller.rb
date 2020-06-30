class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    render status: 200, json: {}
    return
  end
end
