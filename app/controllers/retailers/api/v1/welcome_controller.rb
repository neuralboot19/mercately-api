module Retailers::Api::V1
  class WelcomeController < Retailers::Api::V1::ApiController
    def ping
      set_response(200, 'Ok') && return if @retailer
    end
  end
end
