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
      prepare_order_data if @exist_order
      prepare_data(customer_info)

      meli_customer = update_or_create_meli_customer(customer_info)

      update_or_create_customer(customer_info, meli_customer)
    end

    private

      def update_or_create_customer(customer_info, meli_customer)
        customer = find_customer
        return unless customer.present?

        id_type = customer_info['identification']&.[]('type')
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

        save_customer_data(customer)
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
          phone_verified: @phone_verified,
          email: @email,
          phone: @phone
        )

        meli_customer
      end

      def find_customer
        Customer.find_or_initialize_by(retailer_id: @retailer.id, meli_nickname: @nickname)
      end

      def prepare_order_data
        @first_name = @order_params['first_name']
        @last_name = @order_params['last_name']
        @email = @order_params['email']
        @phone_area = @order_params['phone']&.[]('area_code')
        @phone = @order_params['phone']&.[]('number')
      end

      def prepare_data(customer_info)
        @first_name = customer_info['first_name'] if @first_name.blank?
        @last_name = customer_info['last_name'] if @last_name.blank?
        @nickname = customer_info['nickname']
        @id_number = customer_info['identification']&.[]('number')
        @email = customer_info['email'] if @email.blank?
        @phone = customer_info['phone']&.[]('number') if @phone.blank?
        @meli_registration_date = customer_info['registration_date']
        @phone_area = customer_info['phone']&.[]('area_code') if @phone_area.blank?
        @phone_verified = customer_info['phone']&.[]('verified')
        @id_number = customer_info['identification']&.[]('number')
        @address = customer_info['address']&.[]('address')
        @city = customer_info['address']&.[]('city')
        @state = customer_info['address']&.[]('state')
        @zip_code = customer_info['address']&.[]('zip_code')
        @country_id = customer_info['country_id']
        @link = customer_info['permalink']
        @points = customer_info['points']
        @ratings_total = customer_info['seller_reputation']&.[]('total')
        @transactions_canceled = customer_info['seller_reputation']
          &.[]('transactions')&.[]('canceled')
        @transactions_completed = customer_info['seller_reputation']
          &.[]('transactions')&.[]('completed')
        @ratings_neutral = customer_info['seller_reputation']
          &.[]('transactions')&.[]('ratings')&.[]('neutral')
        @ratings_positive = customer_info['seller_reputation']
          &.[]('transactions')&.[]('ratings')&.[]('positive')
        @ratings_negative = customer_info['seller_reputation']
          &.[]('transactions')&.[]('ratings')&.[]('negative')
        @seller_reputation_level_id = customer_info['seller_reputation']
          &.[]('level_id')
        @buyer_canceled_transactions = customer_info['buyer_reputation']&.[]('canceled_transactions')
        @buyer_completed_transactions = customer_info['buyer_reputation']
          &.[]('transactions')&.[]('completed')
        @buyer_canceled_paid_transactions = customer_info['buyer_reputation']
          &.[]('transactions')&.[]('canceled')&.[]('paid')
        @buyer_unrated_paid_transactions = customer_info['buyer_reputation']
          &.[]('transactions')&.[]('unrated')&.[]('paid')
        @buyer_unrated_total_transactions = customer_info['buyer_reputation']
          &.[]('transactions')&.[]('unrated')&.[]('total')
        @buyer_not_yet_rated_paid_transactions = customer_info['buyer_reputation']
          &.[]('transactions')&.[]('not_yet_rated')&.[]('paid')
        @buyer_not_yet_rated_total_transactions = customer_info['buyer_reputation']
          &.[]('transactions')&.[]('not_yet_rated')&.[]('total')
      end

      def save_customer_data(customer)
        customer.update!(first_name: @first_name) if customer.first_name.blank? && @first_name.present?
        customer.update!(last_name: @last_name) if customer.last_name.blank? && @last_name.present?
        customer.generate_phone

        customer
      end
  end
end
