module MercadoLibre
  class Products
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
      @utility = MercadoLibre::ProductsUtility.new
      @product_variations = MercadoLibre::ProductVariations.new(@retailer)
      @product_publish = MercadoLibre::ProductPublish.new(@retailer)
      @ml_questions = MercadoLibre::Questions.new(@retailer)
      @ml_categories = MercadoLibre::Categories.new(@retailer)
    end

    def search_items(scroll_id = nil)
      url = @api.prepare_search_items_url(scroll_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      products_to_import = response['results']
      scroll_id = response['scroll_id']
      return if products_to_import.blank? || products_to_import.size.zero?

      import_product(products_to_import)
      search_items(scroll_id)
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
      @product_publish.load_pictures_to_ml(product)
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
      category = @ml_categories.import_category(product_info['category_id'])

      product = Product.create_with(
        title: product_info['title'],
        subtitle: product_info['subtitle'],
        description: description['plain_text'],
        category_id: category.id,
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
        condition: product_info['condition'] == 'new' ? 'new_product' : product_info['condition'],
        meli_permalink: product_info['permalink'],
        ml_attributes: product_info['attributes'],
        meli_status: product_info['status'],
        incoming_variations: product_info['variations'],
        incoming_images: product_info['pictures'],
        retailer: @retailer
      ).find_or_create_by!(meli_product_id: product_info['id'])

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
      new_product = product.new_record? && product_info['parent_item_id'].present?

      product = Product.find_or_initialize_by(meli_product_id: product_info['parent_item_id']) if
        new_product

      product.with_lock do
        return if product_info['status'] == 'closed' &&
                  Product.find_by(meli_product_id: product_info['id']).blank?

        category = @ml_categories.import_category(product_info['category_id'])

        product = @utility.assign_product(product, product_info, @retailer, category, new_product)
        product.incoming_images = product_info['pictures']
        product.incoming_variations = product_info['variations']
        product.save!

        after_save_data(product, product_info, new_product)
      end

      product
    rescue ActiveRecord::RecordNotUnique
      product
    end

    def pull_update(product_id)
      url = @api.get_product_url product_id
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      url = @api.get_product_description_url(product_id)
      conn = Connection.prepare_connection(url)
      response = response.merge(Connection.get_request(conn))

      return if response.blank? ||
                response['error'].present?

      product = update(response)
      @product_publish.automatic_re_publish(product)

      product
    end

    def push_update(product, past_meli_status = nil, set_active = nil)
      set_closed = past_meli_status == 'active' && product.meli_status == 'closed'

      if past_meli_status == 'closed' && set_active
        @product_publish.re_publish_product(product)
      elsif product.meli_status != 'closed' || set_closed
        @product_publish.send_update(product, past_meli_status)
      end
    end

    def load_main_picture(product, only_main_picture)
      @product_publish.load_pictures_to_ml(product, only_main_picture)
    end

    def push_change_status(product)
      @product_publish.send_status_update(product)
    end

    private

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

      def after_save_data(product, product_info, new_product)
        @product_variations.save_variations(product, product_info['variations'], new_product) if
          product_info['variations'].present?

        pull_images(product, product_info['pictures'])

        @ml_questions.import_inherited_questions(product) if new_product
      end
  end
end
