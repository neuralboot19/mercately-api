module MercadoLibre
  class Messages
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
    end

    def import(message_id)
      url = get_message_url(message_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_message(response) if response
    end

    def save_message(message_info)
      customer = MercadoLibre::Customers.new(@retailer).import(message_info['from']['user_id'])
      Message.create_with(
        order: Order.find_by(meli_order_id: message_info['resource_id']),
        message: message_info['text']['plain'],
        customer: customer
      ).find_or_create_by!(meli_id: message_info['id'])
    end

    def answer_message(message)
      url = post_answer_url
      conn = Connection.prepare_connection(url)
      Connection.post_request(conn, prepare_message_answer(message))
    end

    private

      def prepare_message_answer(message)
        {
          "from": {
            "user_id": @meli_retailer.meli_user_id
          },
          "to": [
            {
              "user_id": message.customer.meli_user_id,
              "resource": 'orders',
              "resource_id": message.order.meli_order_id,
              "site_id": 'MEC'
            }
          ],
          "text": {
            "plain": message.answer
          }
        }.to_json
      end

      def get_message_url(message_id)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/messages/#{message_id}?#{params.to_query}"
      end

      def post_answer_url
        params = {
          access_token: @meli_retailer.access_token,
          application_id: ENV['MERCADO_LIBRE_ID']
        }
        "https://api.mercadolibre.com/messages?#{params.to_query}"
      end
  end
end
