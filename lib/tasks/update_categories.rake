desc 'Updates ML categories'
task update_categories: :environment do
  puts 'Downloading categories'
  ActiveRecord::Base.transaction do
    @ml_array = []
    faraday_request_get('https://api.mercadolibre.com/sites/MEC/categories').each do |res|
      father = Category.find_or_create_by(meli_id: res['id'])
      father.update(name: res['name'])
      ml_category_import(father, res['id'])
    end
  end
  puts 'Done.'
  puts 'Updating categories'
  ActiveRecord::Base.transaction do
    Product.where.not(meli_product_id: nil).each do |product|
      next unless product.retailer.meli_retailer
      MercadoLibre::Products.new(product.retailer).pull_update(product.meli_product_id)
    end

    @ml_array = @ml_array.compact.uniq
    current_array = Category.pluck(:meli_id).compact.uniq
    current_array -= @ml_array

    Category.where(meli_id: current_array).update_all(status: 'inactive')
  end
  Categories::UpdateJob.perform_at(Date.today.end_of_day + 2.hours)
  puts 'Done.'
end

def ml_category_import(father, cat_id)
  @ml_array << cat_id
  template = faraday_request_get("https://api.mercadolibre.com/categories/#{cat_id}/attributes")
  father.update(template: template) if template.present?
  meli_url = 'https://api.mercadolibre.com/categories/'
  faraday_request_get("#{meli_url}#{cat_id}")['children_categories'].each do |children_category|
    child = Category.find_or_create_by(meli_id: children_category['id'])
    child.update(name: children_category['name'], parent_id: father.id)

    grandchild_count = faraday_request_get("#{meli_url}#{children_category['id']}")['children_categories'].count
    if grandchild_count.positive?
      ml_category_import(child, children_category['id'])
    else
      @ml_array << child.meli_id
      template = faraday_request_get("https://api.mercadolibre.com/categories/#{child.meli_id}/attributes")
      child.update(template: template) if template.present?
      child
    end
  end
end

def faraday_request_get(url)
  conn = Connection.prepare_connection(url)
  Connection.get_request(conn)
rescue
  Raven.capture_exception 'Error al actualizar las categorias de MercadoLibre, se reintentara en 15 minutos.'
  Categories::UpdateJob.perform_in(15.minutes)
end
