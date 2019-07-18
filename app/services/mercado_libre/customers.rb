module MercadoLibre
  class Customers
    def initialize(retailer, order_params = {})
      @retailer = retailer
      @order_params = order_params
      @meli_retailer = @retailer.meli_retailer
      @exist_order = @order_params.present?
    end

    def import(customer_id)
      url = get_customer_url(customer_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      create(response) if response
    end

    def create(customer_info)
      @email = @exist_order ? @order_params['email'] : customer_info['email']
      @phone = @exist_order ? @order_params['phone']&.[]('number') : customer_info['phone']&.[]('number')
      @nickname = @exist_order ? @order_params['nickname'] : customer_info['nickname']
      @first_name = @exist_order ? @order_params['first_name'] : customer_info['first_name']
      @last_name = @exist_order ? @order_params['last_name'] : customer_info['last_name']

      meli_customer = update_or_create_meli_customer(customer_info)

      update_or_create_customer(meli_customer)
    end

    private

      def update_or_create_customer(meli_customer)
        customer = find_customer
        return unless customer.present?

        customer.update_attributes!(
          first_name: @first_name,
          last_name: @last_name,
          email: @email,
          retailer: @retailer,
          meli_nickname: @nickname,
          meli_customer: meli_customer
        )

        customer
      end

      def update_or_create_meli_customer(customer_info)
        meli_customer = MeliCustomer.find_or_initialize_by(meli_user_id: customer_info['id'])

        meli_customer.update_attributes!(
          email: @email,
          phone: @phone,
          nickname: @nickname,
          link: customer_info['permalink'],
          points: customer_info['points'],
          ratings_total: customer_info['seller_reputation']['total'],
          transactions_canceled: customer_info['seller_reputation']['transactions']['canceled'],
          transactions_completed: customer_info['seller_reputation']['transactions']['completed'],
          ratings_neutral: customer_info['seller_reputation']['transactions']['ratings']['neutral'],
          ratings_positive: customer_info['seller_reputation']['transactions']['ratings']['positive'],
          ratings_negative: customer_info['seller_reputation']['transactions']['ratings']['negative'],
          seller_reputation_level_id: customer_info['seller_reputation']['level_id']
        )

        meli_customer
      end

      def find_customer
        if @exist_order.present?
          Customer.find_or_initialize_by(retailer_id: @retailer.id, email: @email)
        else
          Customer.find_or_initialize_by(retailer_id: @retailer.id, meli_nickname: @nickname)
        end
      end

      def get_customer_url(customer_id)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/users/#{customer_id}?#{params.to_query}"
      end
  end
end
