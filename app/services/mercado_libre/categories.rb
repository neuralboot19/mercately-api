module MercadoLibre
  class Categories
    attr_reader :api

    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
    end

    def import_category(category_meli_id)
      category = Category.find_by(meli_id: category_meli_id)
      return category if category.present?

      url = @api.get_category_url(category_meli_id)
      response = prepare_request(url)
      return response if response['error'].present?

      category = Category.find_or_create_by(meli_id: response['id'], name: response['name'])
      url = @api.get_category_attributes_url(category_meli_id)
      attributes = prepare_request(url)
      category.update(template: attributes) if attributes.present?
      save_ancestry(response)
      category
    end

    def save_ancestry(category)
      ancestors = category['path_from_root']
      ancestors_size = ancestors.size

      ancestors.each_with_index do |ancestor, index|
        cat = Category.find_or_create_by(meli_id: ancestor['id'], name: ancestor['name'])
        break if index + 1 >= ancestors_size

        child = Category.find_or_create_by(meli_id: ancestors[index + 1]['id'], name: ancestors[index + 1]['name'])
        child.update(parent_id: cat.id)
      end
    end

    def prepare_request(url)
      conn = Connection.prepare_connection(url)
      Connection.get_request(conn)
    end
  end
end
