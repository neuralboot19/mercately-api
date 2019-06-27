module MercadoLibre
  class Utility
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
        'pictures': prepare_images(product)
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
      {
        'title': product.title,
        'price': product.price.to_f,
        'category_id': product.category.meli_id,
        'available_quantity': product.available_quantity || 0,
        'buying_mode': product.buying_mode,
        'condition': final_condition(product)
        # 'listing_type_id': 'free'
      }.to_json
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
  end
end
