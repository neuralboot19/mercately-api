module Facebook
  class Messages
    def initialize(facebook_retailer)
      @facebook_retailer = facebook_retailer
    end

    def save(message_data)
      customer = Facebook::Customers.new(@facebook_retailer).import(message_data['sender']['id'])
      message = FacebookMessage.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        uid: message_data['sender']['id'],
        id_client: message_data['sender']['id'],
        text: message_data['message']['text'],
        reply_to: message_data['message']&.[]('reply_to')&.[]('mid')
      ).find_or_create_by(mid: message_data['message']['mid'])
      if message.persisted?
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          FacebookMessageSerializer.new(message)
        ).serializable_hash
        FacebookMessagesChannel.broadcast_to customer, serialized_data
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          CustomerSerializer.new(customer)
        ).serializable_hash
        CustomersChannel.broadcast_to @facebook_retailer.retailer, serialized_data
      end
    end

    def import_delivered(message_id, psid)
      url = message_url(message_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_delivered(response, psid) if response
    end

    def save_delivered(response, psid)
      customer = Customer.find_by(psid: psid)
      FacebookMessage.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        uid: @facebook_retailer.uid,
        id_client: psid,
        text: response['message']
      ).find_or_create_by(mid: response['id'])
    end

    def send_message(to, message)
      url = send_message_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_message(to, message))
      JSON.parse(response.body)
    end

    private

      def prepare_message(to, message)
        {
          "recipient": {
            "id": to
          },
          "message": {
            "text": message
          }
        }.to_json
      end

      def send_message_url
        params = {
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/v5.0/me/messages?#{params.to_query}"
      end

      def message_url(message_id)
        params = {
          fields: 'message,attachments,created_time,to,from',
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/#{message_id}?#{params.to_query}"
      end
  end
end
