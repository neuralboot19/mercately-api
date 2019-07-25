module MercadoLibre
  class Products
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
      @utility = MercadoLibre::ProductsUtility.new
      @product_variations = MercadoLibre::ProductVariations.new(@retailer)
    end

    def search_items
      url = @api.prepare_search_items_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      products_to_import = response['results']
      import_product(products_to_import) if products_to_import
    end

    def import_product(products)
      products.map do |product|
        url = @api.get_product_url(product)
        conn = Connection.prepare_connection(url)
        response = Connection.get_request(conn)
        description = import_product_description(response)
        save_product(response, description)
      end
    end

    def import_product_description(product)
      url = @api.get_product_description_url(product['id'])
      conn = Connection.prepare_connection(url)
      Connection.get_request(conn)
    end

    def create(product)
      load_pictures_to_ml(product)
      url = @api.prepare_products_creation_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, @utility.prepare_product(product.reload))
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
      product_exist = Product.find_by(meli_product_id: product_info['id']).present?

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
        ml_attributes: product_info['attributes'],
        meli_status: product_info['status'],
        retailer: @retailer
      ).find_or_create_by!(meli_product_id: product_info['id'])

      return product if product_exist

      @product_variations.save_variations(product, product_info['variations']) if
        product_info['variations'].present?

      images = product_info['pictures']
      images.each_with_index do |img, index|
        product.attach_image(img['url'], img['id'], index)
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
      product.initial_quantity = product_info['initial_quantity']
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
      product.ml_attributes = product_info['attributes']
      product.meli_status = product_info['status']
      product.retailer = @retailer
      product.save!

      @product_variations.save_variations(product, product_info['variations']) if
        product_info['variations'].present?

      pull_images(product, product_info['pictures'])

      product
    end

    def pull_update(product_id)
      url = @api.get_product_url product_id
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      url = @api.get_product_description_url(product_id)
      conn = Connection.prepare_connection(url)
      response = response.merge(Connection.get_request(conn))
      update(response) if response
    end

    def push_update(product)
      url = @api.get_product_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      response = Connection.put_request(conn, @utility.prepare_product_update(product))
      push_description_update(product)
      if response.status == 200
        load_pictures_to_ml(product)
      else
        puts response.body
      end
    end

    def push_description_update(product)
      url = @api.get_product_description_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      Connection.put_request(conn, @utility.prepare_product_description_update(product))
    end

    def load_main_picture(product, only_main_picture)
      load_pictures_to_ml(product, only_main_picture)
    end

    private

      def load_pictures_to_ml(product, only_main_picture = false)
        return if product.images.blank?

        @url = @api.prepare_load_pictures_url
        @url_pic_product = @api.prepare_link_pictures_to_product_url(product)
        product.images.each do |img|
          next unless img.filename.to_s.include?('.')
          next if img.id != product.main_picture_id && only_main_picture

          load_image(product, img)
        end
      end

      def load_image(product, img)
        file = "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{img.key}"

        tempfile = { source: file.to_s }.to_json
        conn = Connection.prepare_connection(@url)
        response = Connection.post_request(conn, tempfile)

        if product.meli_product_id.blank?
          body = JSON.parse(response.body)
          ActiveStorage::Blob.find_by(key: img.key).update(filename: body['id'])
          return
        end

        if response.status == 201
          body = JSON.parse(response.body)

          params = { id: body['id'] }.to_json
          conn = Connection.prepare_connection(@url_pic_product)
          response = Connection.post_request(conn, params)

          ActiveStorage::Blob.find_by(key: img.key).update(filename: body['id']) if response.status == 200
        else
          puts response.body
        end
      end

      def pull_images(product, pictures)
        if product.images.blank?
          pictures.each_with_index do |pic, index|
            product.attach_image(pic['url'], pic['id'], index)
          end
        else
          current_images = product.images.map { |im| im.filename.to_s }
          pictures.each_with_index do |pic, index|
            if current_images.include?(pic['id'])
              update_main_picture_product(product, pic['id']) if index.zero?

              current_images -= [pic['id']]
              next
            end

            product.attach_image(pic['url'], pic['id'], index)
          end

          if current_images.present?
            deleted_ids = ActiveStorage::Blob.where(filename: current_images).pluck(:id)
            product.images.where(blob_id: deleted_ids).purge
          end
        end
      end

      def update_main_picture_product(product, image_id)
        id = ActiveStorage::Blob.find_by(filename: image_id)&.id
        attach_id = product.images.find_by(blob_id: id)&.id if id.present?
        product.update(main_picture_id: attach_id) if attach_id.present?
      end
  end
end
