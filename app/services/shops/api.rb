module Shops
  class Api
    def initialize(retailer)
      @retailer = retailer.reload
      @shops_url = case ENV['ENVIRONMENT']
                   when 'production'
                     "https://#{@retailer.catalog_slug}.mercately.shop"
                   when 'staging'
                     "https://#{@retailer.catalog_slug}.mercately.online"
                   else
                     "http://#{@retailer.catalog_slug}.#{ENV['SHOPS_BASE_URL']}"
                   end
    end

    def create(params = {})
      body = {
        retailer: {
          name: @retailer.name,
          description: @retailer.description,
          country: @retailer.country_code,
          currency: @retailer.currency_symbol,
          unique_key: @retailer.unique_key,
          web_id: @retailer.slug,
          catalog_slug: @retailer.catalog_slug
        }
      }
      body.merge!(params)
      response = HTTParty.post(
        "#{@shops_url}/api/v1/retailers",
        body: body,
        headers: {
          'MERCATELY-AUTH-TOKEN': ENV['MERCATELY_AUTH_TOKEN']
        }
      )
      raise("Shops Response: #{response.code}, #{response.parsed_response}") if response.code != 200

      response.parsed_response
    end

    def update(params = {})
      body = {
        retailer: {
          name: @retailer.name,
          description: @retailer.description,
          country: @retailer.country_code,
          currency: @retailer.currency_symbol,
          catalog_slug: @retailer.catalog_slug
        }
      }
      body.merge!(params)
      response = HTTParty.put(
        "#{@shops_url}/api/v1/retailers/#{@retailer.slug}",
        body: body,
        headers: {
          'RETAILER-KEY': @retailer.unique_key,
          'MERCATELY-AUTH-TOKEN': ENV['MERCATELY_AUTH_TOKEN']
        }
      )
      raise("Shops Response: #{response.code}, #{response.parsed_response}") if response.code != 200

      response.parsed_response
    end
  end
end
