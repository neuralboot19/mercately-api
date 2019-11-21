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
      is_an_answer = false
      customer = if message_info['from']['user_id'] == @meli_retailer.meli_user_id
                   is_an_answer = true
                   MercadoLibre::Customers.new(@retailer).import(message_info['to'][0]['user_id'])
                 else
                   MercadoLibre::Customers.new(@retailer).import(message_info['from']['user_id'])
                 end

      message = Message.find_or_initialize_by(meli_id: message_info['message_id'])
      order = Order.find_by(meli_order_id: message_info['resource_id'])

      message.update_attributes!(
        order: order,
        customer: customer,
        meli_question_type: Question.meli_question_types[:from_order]
      )

      action = 'add'
      if message_info['date_read'].present?
        action = 'subtract'
        total_unread = order.messages.where(date_read: nil, answer: nil).where('created_at <= ?', message.created_at)
          .update_all(date_read: message_info['date_read'])
      end

      if message_info['from']['user_id'] == @meli_retailer.meli_user_id
        message.update(answer: message_info['text']['plain'], sender_id: @retailer.retailer_user.id)
      else
        message.update(question: message_info['text']['plain'])
      end

      return if is_an_answer

      CounterMessagingChannel.broadcast_to(@retailer.retailer_user, identifier:
        '#item__cookie_message', action: action, q: total_unread, total:
        @retailer.unread_messages.size)
    end

    def answer_message(message)
      url = post_answer_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_message_answer(message))
      JSON.parse(response.body)
    end

    private

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
