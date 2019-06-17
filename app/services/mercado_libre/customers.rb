module MercadoLibre
  class Customers
    def initialize(retailer, order_params = {})
      @retailer = retailer
      @order_params = order_params
      @meli_retailer = @retailer.meli_retailer
    end

    def import(customer_id)
      url = get_customer_url(customer_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      create(response) if response
    end

    def create(customer_info)
      customer = Customer.create_with(
        first_name: @order_params['first_name'],
        last_name: @order_params['last_name'],
        email: @order_params['email'],
        retailer: @retailer
      ).find_or_create_by!(email: @order_params['email'])

      MeliCustomer.create_with(
        customer: customer,
        email: @order_params['email'],
        phone: @order_params['phone']&.[]('number'),
        nickname: @order_params['nickname'],
        link: customer_info['permalink'],
        points: customer_info['points'],
        ratings_total: customer_info['seller_reputation']['total'],
        transactions_canceled: customer_info['seller_reputation']['transactions']['canceled'],
        transactions_completed: customer_info['seller_reputation']['transactions']['completed'],
        ratings_neutral: customer_info['seller_reputation']['transactions']['ratings']['neutral'],
        ratings_positive: customer_info['seller_reputation']['transactions']['ratings']['positive'],
        ratings_negative: customer_info['seller_reputation']['transactions']['ratings']['negative'],
        seller_reputation_level_id: customer_info['seller_reputation']['level_id']
      ).find_or_create_by!(meli_user_id: customer_info['id'])

      customer
    end

    private

      def get_customer_url(customer_id)
        "https://api.mercadolibre.com/users/#{customer_id}"
      end
  end
end
