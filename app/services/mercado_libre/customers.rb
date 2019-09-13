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
      prepare_data(customer_info)

      meli_customer = update_or_create_meli_customer(customer_info)

      update_or_create_customer(customer_info, meli_customer)
    end

    private

      def update_or_create_customer(customer_info, meli_customer)
        customer = find_customer
        return unless customer.present?

        id_type = @exist_order ? @order_params['identification']&.[]('type') : customer_info['identification']&.[]('type')
        id_type.downcase! if id_type.present?

        customer.update_attributes!(
          retailer: @retailer,
          meli_nickname: @nickname,
          meli_customer: meli_customer,
          id_type: id_type,
          id_number: @id_number,
          address: @address,
          city: @city,
          state: @state,
          zip_code: @zip_code,
          country_id: @country_id
        )

        customer.update!(first_name: @first_name) if @first_name.present?
        customer.update!(last_name: @last_name) if @last_name.present?

        customer
      end

      def update_or_create_meli_customer(customer_info)
        meli_customer = MeliCustomer.find_or_initialize_by(meli_user_id: customer_info['id'])

        meli_customer.update_attributes!(
          nickname: @nickname,
          link: @link,
          points: @points,
          ratings_total: @ratings_total,
          transactions_canceled: @transactions_canceled,
          transactions_completed: @transactions_completed,
          ratings_neutral: @ratings_neutral,
          ratings_positive: @ratings_positive,
          ratings_negative: @ratings_negative,
          seller_reputation_level_id: @seller_reputation_level_id,
          buyer_canceled_transactions: @buyer_canceled_transactions,
          buyer_completed_transactions: @buyer_completed_transactions,
          buyer_canceled_paid_transactions: @buyer_canceled_paid_transactions,
          buyer_unrated_paid_transactions: @buyer_unrated_paid_transactions,
          buyer_unrated_total_transactions: @buyer_unrated_total_transactions,
          buyer_not_yet_rated_paid_transactions: @buyer_not_yet_rated_paid_transactions,
          buyer_not_yet_rated_total_transactions: @buyer_not_yet_rated_total_transactions,
          meli_registration_date: @meli_registration_date,
          phone_area: @phone_area,
          phone_verified: @phone_verified
        )

        meli_customer.update!(email: @email) if @email.present?
        meli_customer.update!(phone: @phone) if @phone.present?

        meli_customer
      end

      def find_customer
        Customer.find_or_initialize_by(retailer_id: @retailer.id, meli_nickname: @nickname)
      end

      def prepare_data(customer_info)
        if @exist_order
          @email = @order_params['email']
          @phone = @order_params['phone']&.[]('number')
          @nickname = @order_params['nickname']
          @first_name = @order_params['first_name']
          @last_name = @order_params['last_name']
          @link = @order_params['permalink'],
          @points = @order_params['points'],
          @ratings_total = @order_params['seller_reputation']['total'],
          @transactions_canceled = @order_params['seller_reputation']['transactions']['canceled'],
          @transactions_completed = @order_params['seller_reputation']['transactions']['completed'],
          @ratings_neutral = @order_params['seller_reputation']['transactions']['ratings']['neutral'],
          @ratings_positive = @order_params['seller_reputation']['transactions']['ratings']['positive'],
          @ratings_negative = @order_params['seller_reputation']['transactions']['ratings']['negative'],
          @seller_reputation_level_id = @order_params['seller_reputation']['level_id'],
          @buyer_canceled_transactions = @order_params['buyer_reputation']&.[]('canceled_transactions'),
          @buyer_completed_transactions = @order_params['buyer_reputation']
            &.[]('transactions')&.[]('completed'),
          @buyer_canceled_paid_transactions = @order_params['buyer_reputation']
            &.[]('transactions')&.[]('canceled')&.[]('paid'),
          @buyer_unrated_paid_transactions = @order_params['buyer_reputation']
            &.[]('transactions')&.[]('unrated')&.[]('paid'),
          @buyer_unrated_total_transactions = @order_params['buyer_reputation']
            &.[]('transactions')&.[]('unrated')&.[]('total'),
          @buyer_not_yet_rated_paid_transactions = @order_params['buyer_reputation']
            &.[]('transactions')&.[]('not_yet_rated')&.[]('paid'),
          @buyer_not_yet_rated_total_transactions = @order_params['buyer_reputation']
            &.[]('transactions')&.[]('not_yet_rated')&.[]('total'),
          @meli_registration_date: @order_params['registration_date'],
          @phone_area = @order_params['phone']&.[]('area_code'),
          @phone_verified = @order_params['phone']&.[]('verified')
          @id_number = @order_params['identification']&.[]('number'),
          @address = @order_params['address']&.[]('address'),
          @city = @order_params['address']&.[]('city'),
          @state = @order_params['address']&.[]('state'),
          @zip_code = @order_params['address']&.[]('zip_code'),
          @country_id = @order_params['country_id']
        else
          @email = customer_info['email']
          @phone = customer_info['phone']&.[]('number')
          @nickname = customer_info['nickname']
          @first_name = customer_info['first_name']
          @last_name = customer_info['last_name']
          @link = customer_info['permalink'],
          @points = customer_info['points'],
          @ratings_total = customer_info['seller_reputation']['total'],
          @transactions_canceled = customer_info['seller_reputation']['transactions']['canceled'],
          @transactions_completed = customer_info['seller_reputation']['transactions']['completed'],
          @ratings_neutral = customer_info['seller_reputation']['transactions']['ratings']['neutral'],
          @ratings_positive = customer_info['seller_reputation']['transactions']['ratings']['positive'],
          @ratings_negative = customer_info['seller_reputation']['transactions']['ratings']['negative'],
          @seller_reputation_level_id = customer_info['seller_reputation']['level_id'],
          @buyer_canceled_transactions = customer_info['buyer_reputation']&.[]('canceled_transactions'),
          @buyer_completed_transactions = customer_info['buyer_reputation']
            &.[]('transactions')&.[]('completed'),
          @buyer_canceled_paid_transactions = customer_info['buyer_reputation']
            &.[]('transactions')&.[]('canceled')&.[]('paid'),
          @buyer_unrated_paid_transactions = customer_info['buyer_reputation']
            &.[]('transactions')&.[]('unrated')&.[]('paid'),
          @buyer_unrated_total_transactions = customer_info['buyer_reputation']
            &.[]('transactions')&.[]('unrated')&.[]('total'),
          @buyer_not_yet_rated_paid_transactions = customer_info['buyer_reputation']
            &.[]('transactions')&.[]('not_yet_rated')&.[]('paid'),
          @buyer_not_yet_rated_total_transactions = customer_info['buyer_reputation']
            &.[]('transactions')&.[]('not_yet_rated')&.[]('total'),
          @meli_registration_date: customer_info['registration_date'],
          @phone_area = customer_info['phone']&.[]('area_code'),
          @phone_verified = customer_info['phone']&.[]('verified')
          @id_number = customer_info['identification']&.[]('number'),
          @address = customer_info['address']&.[]('address'),
          @city = customer_info['address']&.[]('city'),
          @state = customer_info['address']&.[]('state'),
          @zip_code = customer_info['address']&.[]('zip_code'),
          @country_id = customer_info['country_id']
        end
      end
  end
end
