module MercadoLibre
  class Questions
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
    end

    def import(question_id)
      url = get_question_url(question_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_question(response) if response&.[]('id').present?
    end

    def save_question(question_info)
      customer = MercadoLibre::Customers.new(@retailer).import(question_info['from']['id'])
      question = Question.find_or_initialize_by(meli_id: question_info['id'])
      product = Product.find_by(meli_product_id: question_info['item_id']) || MercadoLibre::Products.new(@retailer)
        .import_product([question_info['item_id']]).first

      question.update_attributes!(
        product: product,
        question: question_info['text'],
        hold: ActiveModel::Type::Boolean.new.cast(question_info['hold']),
        deleted_from_listing: ActiveModel::Type::Boolean.new.cast(question_info['deleted_from_listing']),
        status: question_info['status'],
        answer: question_info['answer']&.[]('text'),
        customer: customer,
        answer_status: question_info['answer']&.[]('status'),
        date_created_answer: question_info['answer']&.[]('date_created'),
        date_created_question: question_info['date_created'],
        meli_question_type: Question.meli_question_types[:from_product]
      )

      CounterMessagingChannel.broadcast_to(@retailer.retailer_user, identifier:
        '#item__cookie_question', action: 'add', total: @retailer.unread_questions.size)
    end

    def answer_question(question)
      url = post_answer_url
      conn = Connection.prepare_connection(url)
      Connection.post_request(conn, prepare_question_answer(question))
    end

    def import_inherited_questions(product)
      url = @api.get_questions_url(product.meli_product_id, 'UNANSWERED')
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      questions = response['questions']

      return unless questions.present?

      questions.each do |q|
        next if Question.check_unique_question_meli_id(q['id'])

        save_question(q)
      end
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
