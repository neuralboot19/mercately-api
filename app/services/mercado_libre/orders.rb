module MercadoLibre
  class Orders
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
      @order_utility = MercadoLibre::OrdersUtility.new
    end

    def import(order_id)
      url = @api.get_order_url(order_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_order(response) if response
    end

    def save_order(order_info)
      customer = MercadoLibre::Customers.new(@retailer, order_info['buyer']).import(order_info['buyer']['id'])

      order_info['status'] = 'invalid_order' if order_info['status'] == 'invalid'
      order = Order.find_or_initialize_by(meli_order_id: order_info['id'])

      order.update_attributes!(
        customer: customer,
        total_amount: order_info['total_amount'],
        currency_id: order_info['currency_id'],
        merc_status: order_info['status']
      )

      order_info['order_items'].each do |order_item|
        product = MercadoLibre::Products.new(@retailer).pull_update(order_item['item']['id'])

        item = OrderItem.find_or_initialize_by(order_id: order.id, product_id: product.id)

        product_variation = ProductVariation.find_by(variation_meli_id: order_item['item']['variation_id']) if
          order_item['item']['variation_id'].present?

        item.update_attributes!(
          quantity: order_item['quantity'],
          unit_price: order_item['unit_price'],
          product_variation_id: product_variation&.id,
          from_ml: true
        )
      end

      return order unless order_info['feedback']&.[]('sale').present?

      status = order_info['feedback']['sale']['fulfilled'] == false ? 'cancelled' : 'success'
      order.update(feedback_rating: order_info['feedback']['sale']['rating'], status: status)
      order
    end

    def push_feedback(order)
      url = @api.prepare_order_feedback_url(order.meli_order_id)
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, @order_utility.prepare_order_feedback(order))

      puts response.body if response.status != 201
    end
  end
end
