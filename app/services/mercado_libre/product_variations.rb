module MercadoLibre
  class ProductVariations
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
      @utility = MercadoLibre::ProductsUtility.new
    end

    def create_product_variations(product)
      url = @api.get_product_url(product.meli_product_id)
      product.product_variations.each do |var|
        conn = Connection.prepare_connection(url)
        response = Connection.put_request(conn, @utility.prepare_variation_product(var, product))

        if response.status == 200
          body = JSON.parse(response.body)
          var.update_data(body)
        else
          puts response.body
        end
      end
    end

    def save_variations(product, variations)
      current_variations = product.product_variations.pluck(:variation_meli_id).compact
      variation_ids = variations.map { |var| var['id'] }.compact
      current_variations -= variation_ids if current_variations.present?

      variations.each do |var|
        product_variation = product.product_variations
          .find_or_initialize_by(variation_meli_id: var['id'])
        product_variation.data = var
        product_variation.save!
      end

      return unless current_variations.present?

      product.product_variations.where(variation_meli_id: current_variations).delete_all
    end
  end
end
