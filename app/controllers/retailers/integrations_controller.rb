class Retailers::IntegrationsController < RetailersController

  def index
  end

  def connect_to_ml
    byebug
    code = params[:code]
    # https://api.mercadolibre.com/oauth/token?grant_type=authorization_code&client_id=APP_ID&client_secret=SECRET_KEY&code=SERVER_GENERATED_AUTHORIZATION_CODE&redirect_uri=REDIRECT_URI
  end
end
