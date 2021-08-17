module Facebook
  class Customers
    def initialize(facebook_retailer, type = 'messenger')
      @type = type
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
      if response['name']
        partition_name = response['name'].partition(' ')
        response['first_name'] = partition_name.first
        response['last_name'] = partition_name.last
      end
      if @customer.present?
        @customer.update_attributes(first_name: response['first_name'], last_name: response['last_name'], pstype: @type)
      else
        # Hago el find para hacer un chequeo previo en la DB por si ya existe, en caso de mucha concurrencia.
        @customer = Customer.find_or_create_by(psid: psid)
        @customer.update_attributes(
          retailer: @facebook_retailer.retailer,
          first_name: response['first_name'],
          last_name: response['last_name'],
          pstype: @type
        )
      end
    end

    private

      def prepare_person_url(psid)
        params = if @type == 'instagram'
                   {
                     fields: 'name',
                     access_token: @facebook_retailer.access_token
                   }
                 else
                   {
                     fields: 'first_name,last_name,profile_pic',
                     access_token: @facebook_retailer.access_token
                   }
                 end
        "https://graph.facebook.com/#{psid}?#{params.to_query}"
      end
  end
end
