module MercadoLibre
  class Products
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
    end

    def search_items
      url = prepare_search_items_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      products_to_import = response['results']
      import_product(products_to_import) if products_to_import
    end

    def import_product(products)
      products.map do |product|
        url = get_product_url(product)
        conn = Connection.prepare_connection(url)
        response = Connection.get_request(conn)
        description = import_product_description(response)
        save_product(response, description)
      end
    end

    def import_product_description(product)
      url = get_product_description_url(product['id'])
      conn = Connection.prepare_connection(url)
      Connection.get_request(conn)
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
      product = Product.create_with(
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
        condition: product_info['condition'] == 'new' ? 'new_product' : product_info['condition'],
        meli_permalink: product_info['permalink'],
        retailer: @retailer
      ).find_or_create_by!(meli_product_id: product_info['id'])

      if product
        images = product_info['pictures']
        images.each do |img|
          product.attach_image(img['url'], img['id'])
        end
      end

      product
    end

    def update(product_info)
      product = Product.find_or_initialize_by(meli_product_id: product_info['id'])
      product.title = product_info['title']
      product.description = product_info['plain_text']
      product.category_id = Category.find_by(meli_id: product_info['category_id']).id
      product.price = product_info['price']
      product.base_price = product_info['base_price']
      product.original_price = product_info['original_price']
      product.initial_quantity = if product.initial_quantity
                                   product_info['initial_quantity'] + product.initial_quantity
                                 else
                                   product_info['initial_quantity']
                                 end
      product.available_quantity = product_info['available_quantity']
      # TODO: Push orders to keep sold_quantity updated
      product.sold_quantity = product_info['sold_quantity']
      product.meli_site_id = product_info['site_id']
      product.meli_start_time = product_info['start_time']
      product.meli_stop_time = product_info['stop_time']
      product.meli_end_time = product_info['end_time']
      product.buying_mode = product_info['buying_mode']
      product.meli_listing_type_id = product_info['listing_type_id']
      product.meli_expiration_time = product_info['expiration_time']
      product.condition = product_info['condition'] == 'new' ? 'new_product' : product_info['condition']
      product.meli_permalink = product_info['permalink']
      product.retailer = @retailer
      product.save!
    end

    def pull_update(product_id)
      url = get_product_url product_id
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      response = JSON.parse response.body
      url = get_product_description_url(product_id)
      conn = Connection.prepare_connection(url)
      response = response.merge(JSON.parse(Connection.get_request(conn).body))
      update(response) if response
    end

    def push_update(product)
      url = get_product_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      Connection.put_request(conn, prepare_product_update(product))
      push_description_update(product)
    end

    def push_description_update(product)
      url = get_product_description_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      Connection.put_request(conn, prepare_product_description_update(product))
    end

    private

      def prepare_search_items_url
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/users/#{@meli_retailer.meli_user_id}/items/search?#{params.to_query}"
      end

      def get_product_url(product)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/items/#{product}/?#{params.to_query}"
      end

      def get_product_description_url(product)
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/items/#{product}/description?#{params.to_query}"
      end

      def prepare_products_creation_url
        params = {
          access_token: @meli_retailer.access_token
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
          link = 'http://res.cloudinary.com/' + ENV['CLOUDINARY_CLOUD_NAME'] + '/image/upload/' + img.key
          array << { "source": link.to_s }
        end
        array
      end

      def prepare_product_update(product)
        {
          'title': product.title,
          'price': product.price.to_f,
          'available_quantity': product.available_quantity || 0,
          # 'listing_type_id': 'free',
          'pictures': [
            { "source": 'http://mla-s2-p.mlstatic.com/968521-MLA20805195516_072016-O.jpg' } # PENDIENTE IMAGENES
          ]
        }.to_json
      end

      def prepare_product_description_update(product)
        {
          'plain_text': product.description
        }.to_json
      end
  end
end
