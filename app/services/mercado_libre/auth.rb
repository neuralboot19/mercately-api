module MercadoLibre
  class Auth
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer || MeliRetailer.new(retailer: @retailer)
    end

    def get_access_token_from_url(code)
      url = prepare_access_token_params(code)
      conn = prepare_connection(url)
      conn.post
    end

    def save_access_token(params)
      @meli_retailer.update_attributes(
        access_token: params['access_token'],
        meli_user_id: params['user_id'],
        refresh_token: params['refresh_token']
      )
    end

    def refresh_access_token
      url = prepare_refresh_token_params(@meli_retailer.refresh_token)
      conn = prepare_connection(url)
      response = conn.post
      response = JSON.parse(response.body)
      @meli_retailer.update_attributes(
        access_token: response['access_token'],
        meli_user_id: response['user_id'],
        refresh_token: response['refresh_token']
      )
    end

    private

      def prepare_access_token_params(code)
        params = {
          grant_type: 'authorization_code',
          client_id: ENV['MERCADO_LIBRE_ID'],
          client_secret: ENV['MERCADO_LIBRE_KEY'],
          code: code,
          redirect_uri: ENV['MERCADO_LIBRE_REDIRECT_URI']
        }
        "https://api.mercadolibre.com/oauth/token?#{params.to_query}"
      end

      def prepare_refresh_token_params(refresh_token)
        params = {
          grant_type: 'refresh_token',
          client_id: ENV['MERCADO_LIBRE_ID'],
          client_secret: ENV['MERCADO_LIBRE_KEY'],
          refresh_token: refresh_token
        }
        "https://api.mercadolibre.com/oauth/token?#{params.to_query}"
      end

      def prepare_connection(url)
        Faraday.new(url: url) do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to $stdout
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end
  end
end
