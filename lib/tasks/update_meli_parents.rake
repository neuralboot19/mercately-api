task update_meli_parents: :environment do
  Retailer.all.each do |retailer|
    next unless retailer.meli_retailer

    @api = MercadoLibre::Api.new(retailer.meli_retailer)
    retailer.products.where.not(meli_product_id: nil).each do |product|
      url = @api.get_product_url(product.meli_product_id)
      response = faraday_request_get(url)

      if response['id'].present?
        parents = product.meli_parent

        if response['parent_item_id'].present?
          parents = parents.push(parent: response['parent_item_id'])
          product.update_column(:meli_parent, parents)
        end
      end
    end
  end
end

def faraday_request_get(url)
  conn = Connection.prepare_connection(url)
  Connection.get_request(conn)
end
