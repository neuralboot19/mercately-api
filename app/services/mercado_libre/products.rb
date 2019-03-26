module MercadoLibre
  class Products

    def initialize(retailer)
      @retailer = retailer
      @meli_info = @retailer.meli_info
    end

    def search_items
      url = prepare_search_items_url
      conn = Faraday.new(url: url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to $stdout
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      response = conn.get
      byebug
      response = JSON.parse(response.body)
    end

    def import
      byebug

    end

    private

      def prepare_search_items_url
        params = {
          access_token: @meli_info.access_token,
        }
        "https://api.mercadolibre.com/users/#{@meli_info.meli_user_id}/items/search?#{params.to_query}"
      end


      end

  end
end