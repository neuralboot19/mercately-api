module Facebook
  class Customers
    def initialize(facebook_retailer)
      @facebook_retailer = facebook_retailer
    end

    def import(psid)
      return Customer.find_by(psid: psid) if Customer.exists?(psid: psid)

      url = prepare_person_url(psid)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save(response, psid) if response
    end

    def save(response, psid)
      Customer.create_with(
        retailer: @facebook_retailer.retailer,
        first_name: response['first_name'],
        last_name: response['last_name']
      ).find_or_create_by(psid: psid)
    end

    private

      def prepare_person_url(psid)
        params = {
          fields: 'first_name,last_name,profile_pic',
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/#{psid}?#{params.to_query}"
      end
  end
end
