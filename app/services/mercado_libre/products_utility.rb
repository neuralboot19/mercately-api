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
        'attributes': product.ml_attributes
      }.to_json
    end

    def prepare_images(product)
      array = []
      product.images.each do |img|
        link = img.filename.to_s
        array << { "id": link }
      end
      array
    end

    def prepare_product_update(product)
      variations = prepare_variations_for_update(product)

      info = {
        'title': product.title,
        'variations': variations,
        'attributes': product.ml_attributes
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

      current_images = product.images.map { |im| im.filename.to_s }
      variation.data['picture_ids'] = current_images

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
