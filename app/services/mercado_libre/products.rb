module MercadoLibre
  class Products
    def initialize(retailer)
      @retailer = retailer
      @meli_info = @retailer.meli_info
    end

    def search_items
      url = prepare_search_items_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      response = JSON.parse(response.body)
      products_to_import = response['results']
      import_product(products_to_import) if products_to_import
    end

    def import_product(products)
      products.each do |product|
        url = prepare_products_search_url(product)
        conn = Connection.prepare_connection(url)
        response = Connection.get_request(conn)
        product = JSON.parse(response.body)
        description = import_product_description(product)
        save_product(product, description)
      end
    end

    def import_product_description(product)
      url = get_product_description(product['id'])
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      response = response.status == 200 ? JSON.parse(response.body) : ''
    end

    def create(product)
      url = prepare_products_creation_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_product(product))
      if response.status == 201
        body = JSON.parse(response.body)
        product.update_ml(body)
      else
        puts '\n\n\n\n------- EXCEPTION IN ML -------\n'
        puts response.body
        puts '\n-------------------------------\n\n\n\n'
      end
    end

    def save_product(product_info, description)
      Product.create_with(
        title: product_info['title'],
        subtitle: product_info['subtitle'],
        description: description['plain_text'],
        category_id: Category.find_by(meli_id: product_info['category_id']).id,
        price: product_info['price'],
        base_price: product_info['base_price'],
        original_price: product_info['original_price'],
        initial_quantity: product_info['initial_quantity'],
        available_quantity: product_info['available_quantity'],
        sold_quantity: product_info['sold_quantity'],
        meli_site_id: product_info['site_id'],
        meli_start_time: product_info['start_time'],
        meli_stop_time: product_info['stop_time'],
        meli_end_time: product_info['end_time'],
        buying_mode: product_info['buying_mode'],
        meli_listing_type_id: product_info['listing_type_id'],
        meli_expiration_time: product_info['expiration_time'],
        condition: product_info['condition'],
        meli_permalink: product_info['permalink'],
        retailer: @retailer
      ).find_or_create_by!(meli_product_id: product_info['id'])
    end

    private

      def prepare_search_items_url
        params = {
          access_token: @meli_info.access_token
        }
        "https://api.mercadolibre.com/users/#{@meli_info.meli_user_id}/items/search?#{params.to_query}"
      end

      def prepare_products_search_url(product)
        params = {
          access_token: @meli_info.access_token
        }
        "https://api.mercadolibre.com/items/#{product}/?#{params.to_query}"
      end

      def get_product_description(product)
        params = {
          access_token: @meli_info.access_token
        }
        "https://api.mercadolibre.com/items/#{product}/description?#{params.to_query}"
      end

      def prepare_products_creation_url
        params = {
          access_token: @meli_info.access_token
        }
        "https://api.mercadolibre.com/items?#{params.to_query}"
      end

      def prepare_product(product)
        {
          'title': product.title,
          'category_id': product.category.meli_id,
          'price': product.price.to_f,
          'available_quantity': product.available_quantity || 0,
          'buying_mode': product.buying_mode,
          'currency_id': 'USD',
          'listing_type_id': 'free', # TODO: PENDIENTE ACTIVAR LOS LISTINGS TYPES PARA CADA PRODUCTO
          'condition': product.condition ? product.condition.downcase : 'not_specified',
          'description': { "plain_text": product.description || '' },
          'pictures': prepare_images(product)
        }.to_json
      end

      def prepare_images(product)
        array = []
        product.images.each do |img|
          link = ENV['HOST_URL'] + Rails.application.routes.url_helpers.rails_blob_path(img, only_path: true)
          array << { "source": "#{link}" }
        end
        return array
      end
  end
end
