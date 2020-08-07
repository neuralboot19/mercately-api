module Api::V1
  class WelcomeController < Api::MobileController
    def ping
      set_response(200, 'Ok') && return if @current_retailer_user
    end
  end
end
