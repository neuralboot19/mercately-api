class Retailers::IntegrationsController < RetailersController

  def index
  end

  def connect_to_ml
    code = params[:code]
    # 

    url = 'https://api.mercadolibre.com/oauth/token?grant_type=authorization_code'
    url += "&client_id=#{ENV['MERCADO_LIBRE_ID']}&client_secret=#{ENV['MERCADO_LIBRE_KEY']}"
    url += "&code=#{code}"
    url += "&redirect_uri=https://5906e244.ngrok.io/retailers/integrations/mercadolibre"


    conn = Faraday.new(:url => url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    response = conn.post     # GET http://sushi.com/nigiri/sake.json
    parsed_response = JSON.parse(response.body)


    if response.status == 200
      retailer = current_retailer_user.retailer

      meli_info = retailer.meli_info ? retailer.meli_info : MeliInfo.new(retailer: retailer)

      meli_info.access_token = parsed_response['access_token']
      meli_info.meli_user_id = parsed_response['user_id']
      meli_info.refresh_token = parsed_response['refresh_token']
      meli_info.save
      redirect_to retailers_integrations_path, notice: 'Conectado existosamente'

    else
      redirect_to retailers_integrations_path, notice: 'Error al conectarse'
    end


  end
end


