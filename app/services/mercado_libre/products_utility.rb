module MercadoLibre
  class ProductsUtility
    def prepare_product(product)
      {
        'title': product.title,
        'category_id': product.category.meli_id,
        'price': product.price.to_f,
        'available_quantity': product.available_quantity || 0,
        'buying_mode': product.buying_mode,
        'currency_id': 'USD',
        'listing_type_id': 'free', # TODO: PENDIENTE ACTIVAR LOS LISTINGS TYPES PARA CADA PRODUCTO
        'condition': final_condition(product),
        'description': { "plain_text": product.description || '' },
        'pictures': prepare_images(product),
        'attributes': product.ml_attributes,
        'status': product.meli_status
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

    def prepare_product_update(product)
      variations = prepare_variations_for_update(product)

      info = {
        'title': product.title,
        'variations': variations,
        'attributes': product.ml_attributes,
        'pictures': prepare_images_update(product),
        'status': product.meli_status
        # 'listing_type_id': 'free'
      }

      unless variations.present?
        info['price'] = product.price.to_f
        info['available_quantity'] = product.available_quantity || 0
      end

      if product.sold_quantity.blank? || product.sold_quantity.zero?
        info['category_id'] = product.category.meli_id
        info['buying_mode'] = product.buying_mode
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
               variation.data.except('id')
             else
               variation.data
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
  end
end
