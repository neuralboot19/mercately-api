task update_categories: :environment do
  puts 'Updating categories'
  ActiveRecord::Base.transaction do
    faraday_request_get('https://api.mercadolibre.com/sites/MEC/categories').each do |res|
      father = Category.create(meli_id: res['id'], name: res['name'])
      ml_category_import(father, res['id'])
    end
  end
  puts 'done.'
end

def ml_category_import(father, cat_id)
  meli_url = 'https://api.mercadolibre.com/categories/'
  faraday_request_get("#{meli_url}#{cat_id}")['children_categories'].each do |children_category|
    child = Category.create_with(name: children_category['name'], parent_id: father.id)
      .find_or_create_by(meli_id: children_category['id'])
    child.update(parent_id: father.id) unless child.parent
    grandchild_count = faraday_request_get("#{meli_url}#{children_category['id']}")['children_categories'].count
    if grandchild_count > 0
      ml_category_import(child, children_category['id'])
    else
      child
    end
  end
end

def faraday_request_get(url)
  conn = Faraday.new(url: url) do |faraday|
    faraday.request  :url_encoded
    faraday.response :logger
    faraday.adapter  Faraday.default_adapter
  end

  response = conn.get
  response = JSON.parse(response.body)
end
