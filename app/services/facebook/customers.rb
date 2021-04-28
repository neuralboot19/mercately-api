module Facebook
  class Customers
    def initialize(facebook_retailer)
      @facebook_retailer = facebook_retailer
    end

    def import(psid)
      @customer = Customer.find_by(psid: psid)
      return @customer unless @customer.blank? || @customer.first_name.blank? || @customer.last_name.blank?

      url = prepare_person_url(psid)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save(response, psid) if response

      @customer
    end

    def save(response, psid)
      if @customer.present?
        @customer.update_attributes(first_name: response['first_name'], last_name: response['last_name'])
      else
        # Hago el find para hacer un chequeo previo en la DB por si ya existe, en caso de mucha concurrencia.
        @customer = Customer.find_or_create_by(psid: psid)
        @customer.update_attributes(retailer: @facebook_retailer.retailer, first_name: response['first_name'],
          last_name: response['last_name'])
      end
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
