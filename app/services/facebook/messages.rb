module Facebook
  class Messages
    def initialize(facebook_retailer)
      @facebook_retailer = facebook_retailer
    end

    def send_message(message)
      params = {
        access_token: @facebook_retailer.access_token
      }
      "https://api.mercadolibre.com/items/#{product}/?#{params.to_query}"
    end
  end
end
