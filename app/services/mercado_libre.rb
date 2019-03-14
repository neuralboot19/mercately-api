class MercadoLibre

  def initialize(retailer)
    @retailer = retailer
  end

  def get_access_token_from_url(code)
    url = mercado_libre_url_ec(code)
    conn = Faraday.new(:url => url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    return conn.post
  end

  def save_access_token(params)
    meli_info = @retailer.meli_info ? @retailer.meli_info : MeliInfo.new(retailer: @retailer)
    meli_info.update_attributes(access_token: params['access_token'], 
      meli_user_id:params['user_id'], refresh_token: params['refresh_token'])
  end

  private
  def mercado_libre_url_ec(code)
    params = {
      :grant_type => "authorization_code",
      :client_id => ENV['MERCADO_LIBRE_ID'],
      :client_secret => ENV['MERCADO_LIBRE_KEY'],
      :code => code,
      :redirect_uri => ENV['MERCADO_LIBRE_REDIRECT_URI']
    }
    return "https://api.mercadolibre.com/oauth/token?#{params.to_query}"
  end

end
