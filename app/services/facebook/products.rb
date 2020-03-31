module Facebook
  class Products
    def initialize(retailer)
      @retailer = retailer
    end

    def update_or_upload(product)
      if product.facebook_product_id
        update(product)
      else
        create(product)
      end
    end

    def create(product)
      url = facebook_api.create_product_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_create_product(product))
      body = JSON.parse(response.body)

      if body['error']
        {
          success: false,
          body: body
        }
      else
        product.update(facebook_product_id: body['id'], connected_to_facebook: true)
        {
          success: true,
          body: body
        }
      end
    end

    def update(product)
      url = facebook_api.update_product_url(product)
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_update_product(product))
      body = JSON.parse(response.body)

      if body['error']
        {
          success: false,
          body: body
        }
      else
        {
          success: true,
          body: body
        }
      end
    end

    def delete(product)
      url = facebook_api.delete_product_url(product)
      conn = Connection.prepare_connection(url)
      response = Connection.delete_request(conn)
      body = JSON.parse(response.body)

      if body['error']
        {
          success: false,
          body: body
        }
      else
        product.update(facebook_product_id: nil)
        {
          success: true,
          body: body
        }
      end
    end

    def update_inventory(product)
      url = facebook_api.update_product_url(product)
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_update_inventory(product))
      body = JSON.parse(response.body)

      if body['error']
        {
          success: false,
          body: body
        }
      else
        {
          success: true,
          body: body
        }
      end
    end

    private

      def facebook_api
        @facebook_api = Facebook::Api.new(nil, @retailer.retailer_user_connected_to_fb)
      end

      def prepare_create_product(product)
        data = prepare_data(product)

        {
          'currency': 'USD',
          'image_url': data[:image_url],
          'additional_image_urls': data[:additional_image_urls],
          'name': product.title,
          'price': data[:price],
          'description': product.description,
          'retailer_id': product.web_id,
          'category': product.category.name,
          'url': product.url,
          'brand': product.brand,
          'inventory': product.available_quantity,
          'condition': data[:condition],
          'availability': data[:availability]
        }.to_json
      end

      def prepare_update_product(product)
        data = prepare_data(product)

        {
          'image_url': data[:image_url],
          'additional_image_urls': data[:additional_image_urls],
          'name': product.title,
          'price': data[:price],
          'description': product.description,
          'brand': product.brand,
          'inventory': product.available_quantity,
          'condition': data[:condition],
          'availability': data[:availability],
          'url': product.url
        }.to_json
      end

      def prepare_update_inventory(product)
        {
          'inventory': product.available_quantity
        }.to_json
      end

      def prepare_data(product)
        price = product.price.to_i
        price = price.to_s + '00'
        image = product.main_picture_id ? product.images.find(product.main_picture_id) : product.images.first
        image_url = "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{image.key}"
        additional_image_urls = product.images.map { |img| 'http://res.cloudinary.com/' \
          "#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{img.key}" unless img.key == image.key }

        condition = if product.condition == 'new_product'
                      'new'
                    elsif product.condition == 'not_specified'
                      'used'
                    else
                      product.condition
                    end

        {
          price: price.to_i,
          image_url: image_url,
          additional_image_urls: additional_image_urls.compact,
          condition: condition,
          availability: product.available_quantity.to_i.positive? ? 'in stock' : 'out of stock'
        }
      end
  end
end
