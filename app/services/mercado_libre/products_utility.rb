module MercadoLibre
  class ProductsUtility
    def prepare_product(product)
      {
        'title': product.title,
        'category_id': product.category.meli_id,
        'price': product.price.to_f,
        'available_quantity': product.available_quantity || 0,
        'currency_id': 'USD',
        'listing_type_id': 'free', # TODO: PENDIENTE ACTIVAR LOS LISTINGS TYPES PARA CADA PRODUCTO
        'condition': final_condition(product),
        'description': { "plain_text": product.description || '' },
        'pictures': prepare_images(product),
        'attributes': product.ml_attributes
      }.to_json
    end

    def prepare_images(product)
      array = []
      product.images.each do |img|
        if img.id == product.main_picture_id
          array.unshift("id": img.filename.to_s)
          next
        end

        array << { "id": img.filename.to_s }
      end
      array
    end

    def prepare_images_update(product)
      array = []
      product.images.each do |img|
        next if img.filename.to_s.include?('.')

        if img.id == product.main_picture_id
          array.unshift("id": img.filename.to_s)
          next
        end

        array << { "id": img.filename.to_s }
      end
      array
    end

    def prepare_product_update(product, past_meli_status = nil)
      variations = prepare_variations_for_update(product)

      info = {
        'title': product.title,
        'variations': variations,
        'attributes': product.ml_attributes,
        'pictures': prepare_images_update(product)
        # 'listing_type_id': 'free'
      }

      info['status'] = product.meli_status if
        %w[active paused].include? past_meli_status

      unless variations.present?
        info['price'] = product.price.to_f
        info['available_quantity'] = product.available_quantity || 0
      end

      if include_change_before_bids(product)
        info['category_id'] = product.category.meli_id
        info['condition'] = final_condition(product)
      end

      info.to_json
    end

    def prepare_product_description_update(product)
      {
        'plain_text': product.description
      }.to_json
    end

    def final_condition(product)
      if product.condition
        product.condition == 'new_product' ? 'new' : product.condition
      else
        'not_specified'
      end
    end

    def prepare_variation_product(variation, product)
      load_variations = []
      variation_ids = product.product_variations.pluck(:variation_meli_id).compact

      variation_ids.each do |vid|
        load_variations << { 'id': vid }
      end

      product.images.each do |img|
        if img.id == product.main_picture_id
          variation.data['picture_ids'].unshift(img.filename.to_s)
          next
        end

        variation.data['picture_ids'] << img.filename.to_s
      end

      data = if variation.data['id'].present? && variation.data['id'] == 'undefined'
               variation.data.except('id', 'catalog_product_id')
             else
               variation.data.except('catalog_product_id')
             end

      load_variations << data

      { 'variations': load_variations }.to_json
    end

    def prepare_variations_for_update(product)
      return [] unless product.product_variations.present?

      variations = []
      product.product_variations.each do |var|
        variations << { 'id': var.data['id'], 'price': product.price.to_f } if
          var.data['id'].present? && var.data['id'] != 'undefined'
      end

      variations
    end

    def prepare_re_publish_product(product)
      info = {
        'listing_type_id': 'free',
        'title': product.title
      }

      if product.product_variations.present?
        info['variations'] = []

        product.product_variations.each do |var|
          info['variations'] << {
            'id': var.variation_meli_id,
            'price': var.data['price'].to_f,
            'quantity': var.data['available_quantity'].to_i
          }
        end
      else
        info['price'] = product.price.to_f
        info['quantity'] = product.available_quantity
      end

      info.to_json
    end

    def prepare_product_status_update(product)
      {
        'status': product.meli_status
      }.to_json
    end

    def assign_product(product, product_info, retailer, category, new_product)
      if new_product
        product.meli_product_id = product_info['id']
        product.status = 'active'
      end

      product.title = product_info['title']
      product.description = product_info['plain_text']
      product.category_id = category.id
      product.price = product_info['price']
      product.base_price = product_info['base_price']
      product.original_price = product_info['original_price']
      product.initial_quantity = product_info['initial_quantity']
      product.meli_site_id = product_info['site_id']
      product.meli_start_time = product_info['start_time']
      product.meli_stop_time = product_info['stop_time']
      product.meli_end_time = product_info['end_time']
      product.buying_mode = product_info['buying_mode']
      product.meli_listing_type_id = product_info['listing_type_id']
      product.condition = product_info['condition'] == 'new' ? 'new_product' : product_info['condition']
      product.meli_permalink = product_info['permalink']
      product.ml_attributes = product_info['attributes']
      product.meli_status = product_info['status']
      product.from = 'mercadolibre'
      product.retailer = retailer

      if product_info['status'] == 'closed'
        product.available_quantity = product_info['available_quantity'] if
          update_available_quantity(product, product_info)
      else
        product.available_quantity = product_info['available_quantity']
      end

      product.sold_quantity = product_info['sold_quantity'] if product.new_record?

      product
    end

    def update_available_quantity(product, product_info)
      product.status != 'archived' && product.available_quantity.positive? &&
        product_info['available_quantity'].to_i.zero?
    end

    def include_change_before_bids(product)
      (product.sold_quantity.blank? || product.sold_quantity.zero?) && product.include_before_bids_info?
    end
  end
end
