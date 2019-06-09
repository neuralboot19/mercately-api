module MercadoLibre
  class Questions
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
    end

    def import(question_id)
      url = get_question_url(question_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_question(response) if response
    end

    def save_question(question_info)
      customer = MercadoLibre::Customers.new(@retailer).import(question_info['from']['id'])
      Question.create_with(
        product: Product.find_by(meli_product_id: question_info['item_id']),
        question: question_info['text'],
        answer: question_info['answer']&.[]('text'),
        customer: customer
      ).find_or_create_by!(meli_id: question_info['id'])
    end

    def answer_question(question)
      url = post_answer_url
      conn = Connection.prepare_connection(url)
      Connection.post_request(conn, prepare_question_answer(question))
    end

    private

      def prepare_question_answer(question)
        {
          'question_id': question.meli_id,
          'text': question.answer
        }.to_json
      end

      def get_question_url(question_id)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/questions/#{question_id}?#{params.to_query}"
      end

      def post_answer_url
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/answers?#{params.to_query}"
      end
  end
end
