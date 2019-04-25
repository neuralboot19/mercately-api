module MercadoLibre
  class Orders
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
    end

    def import(order_id)
      url = get_order_url(order_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_order(response) if response
    end

    def save_order(order_info)
      customer = MercadoLibre::Customers.new(@retailer, order_info['buyer']).import(order_info['buyer']['id'])

      order_info['status'] = 'invalid_order' if order_info['status'] == 'invalid'
      order = Order.create_with(
        customer: customer,
        status: order_info['status']
      ).find_or_create_by!(meli_order_id: order_info['id'])

      order_info['order_items'].each do |order_item|
        product = MercadoLibre::Products.new(@retailer).import_product([order_item['item']['id']]).first
        OrderItem.create!(
          order: order,
          product: product,
          quantity: order_item['quantity'],
          unit_price: order_item['unit_price']
        )
      end

      order
    end

    private

      def get_order_url(order_id)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/orders/#{order_id}?#{params.to_query}"
      end
  end
end
