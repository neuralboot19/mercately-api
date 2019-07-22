module MercadoLibre
  class Customers
    def initialize(retailer, order_params = {})
      @retailer = retailer
      @order_params = order_params
      @meli_retailer = @retailer.meli_retailer
      @exist_order = @order_params.present?
      @api = MercadoLibre::Api.new(@meli_retailer)
    end

    def import(customer_id)
      url = @api.get_customer_url(customer_id)
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

      update_or_create_customer(customer_info, meli_customer)
    end

    private

      def update_or_create_customer(customer_info, meli_customer)
        customer = find_customer
        return unless customer.present?

        customer.update_attributes!(
          first_name: @first_name,
          last_name: @last_name,
          email: @email,
          retailer: @retailer,
          meli_nickname: @nickname,
          meli_customer: meli_customer,
          id_type: customer_info['identification']&.[]('type'),
          id_number: customer_info['identification']&.[]('number'),
          address: customer_info['address']&.[]('address'),
          city: customer_info['address']&.[]('city'),
          state: customer_info['address']&.[]('state'),
          zip_code: customer_info['address']&.[]('zip_code'),
          country_id: customer_info['country_id']
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
          seller_reputation_level_id: customer_info['seller_reputation']['level_id'],
          buyer_canceled_transactions: customer_info['buyer_reputation']&.[]('canceled_transactions'),
          buyer_completed_transactions: customer_info['buyer_reputation']&.[]('transactions')&.[]('completed'),
          buyer_canceled_paid_transactions: customer_info['buyer_reputation']&.[]('transactions')&.[]('canceled')&.[]('paid'),
          buyer_unrated_paid_transactions: customer_info['buyer_reputation']&.[]('transactions')&.[]('unrated')&.[]('paid'),
          buyer_unrated_total_transactions: customer_info['buyer_reputation']&.[]('transactions')&.[]('unrated')&.[]('total'),
          buyer_not_yet_rated_paid_transactions: customer_info['buyer_reputation']&.[]('transactions')&.[]('not_yet_rated')&.[]('paid'),
          buyer_not_yet_rated_total_transactions: customer_info['buyer_reputation']&.[]('transactions')&.[]('not_yet_rated')&.[]('total'),
          meli_registration_date: customer_info['registration_date'],
          phone_area: customer_info['phone']&.[]('area_code'),
          phone_verified: customer_info['phone']&.[]('verified')
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
  end
end
