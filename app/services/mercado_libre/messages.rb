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
      send_notification = message.new_record?
      order = Order.find_by(meli_order_id: message_info['resource_id'])

      return if not_corresponding_message(order, customer, is_an_answer)

      message.update_attributes!(
        order: order,
        customer: customer,
        meli_question_type: Question.meli_question_types[:from_order],
        attachments: message_info['attachments'],
        created_at: message_info['date']
      )

      if message_info['date_read'].present?
        unread_messages = order.messages.where(date_read: nil, answer: nil).where('created_at <= ?', message.created_at)
        unread_messages.update_all(date_read: message_info['date_read'])
      end

      if is_an_answer
        message.update(answer: message_info['text']['plain'], sender_id: @retailer.retailer_user.id)
      else
        message.update(question: message_info['text']['plain'])
      end

      insert_notification(is_an_answer, message) if send_notification
    end

    def answer_message(message)
      url = post_answer_url(message)
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

      def insert_notification(is_an_answer, message)
        return if is_an_answer

        ml_helper = MercadoLibreNotificationHelper
        ml_helper.broadcast_data(@retailer, @retailer.retailer_users, 'messages', message)
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
          "text": message.answer
        }.to_json
      end

      def get_message_url(message_id)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/messages/#{message_id}?#{params.to_query}"
      end

      def post_answer_url(message)
        params = {
          access_token: @meli_retailer.access_token,
          application_id: ENV['MERCADO_LIBRE_ID']
        }
        "https://api.mercadolibre.com/messages/packs/#{message.order.pack_id || message.order.meli_order_id}/" \
          "sellers/#{@meli_retailer.meli_user_id}?#{params.to_query}"
      end
  end
end
