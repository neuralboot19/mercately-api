class Api::V1::WhatsappController < ApplicationController
   protect_from_forgery :only => [:create]
   def create
     Rails.logger.info(params)
     render status: 200, json: { message: 'succesful' }
   end
end
