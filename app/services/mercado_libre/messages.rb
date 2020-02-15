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
      is_an_answer = message_info['from']['user_id'] == @meli_retailer.meli_user_id
      customer = find_customer(is_an_answer, message_info)

      message = Message.find_or_initialize_by(meli_id: message_info['message_id'])
      order = Order.find_by(meli_order_id: message_info['resource_id'])

      return if not_corresponding_message(order, customer, is_an_answer)

      message.update_attributes!(
        order: order,
        customer: customer,
        meli_question_type: Question.meli_question_types[:from_order],
        created_at: message_info['date']
      )

      if message_info['date_read'].present?
        order.messages.where(date_read: nil, answer: nil).where('created_at <= ?', message.created_at)
          .update_all(date_read: message_info['date_read'])
      end

      if is_an_answer
        message.update(answer: message_info['text']['plain'], sender_id: @retailer.retailer_user.id)
      else
        message.update(question: message_info['text']['plain'])
      end
    end

    def answer_message(message)
      url = post_answer_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_message_answer(message))
      JSON.parse(response.body)
    end

    private

      def find_customer(is_an_answer, message_info)
        if is_an_answer
          MercadoLibre::Customers.new(@retailer).import(message_info['to'][0]['user_id'])
        else
          MercadoLibre::Customers.new(@retailer).import(message_info['from']['user_id'])
        end
      end

      def not_corresponding_message(order, customer, is_an_answer)
        order.blank? || order.created_at < @meli_retailer.created_at ||
          (is_an_answer && order.retailer_id != @retailer.id) ||
          (is_an_answer == false && order.customer.id != customer.id)
      end

      def prepare_message_answer(message)
        {
          "from": {
            "user_id": @meli_retailer.meli_user_id
          },
          "to": [
            {
              "user_id": message.customer.meli_customer.meli_user_id,
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
