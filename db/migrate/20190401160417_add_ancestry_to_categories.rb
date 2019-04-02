class AddAncestryToCategories < ActiveRecord::Migration[5.2]
  def up
    add_column :categories, :ancestry, :string
    add_index :categories, :ancestry

    ActiveRecord::Base.transaction do
      faraday_request_get('https://api.mercadolibre.com/sites/MEC/categories').each do |res|
        father = Category.create(meli_id: res['id'], name: res['name'])
        choticimo(father, res['id'])
      end
    end
  end

  def down
    remove_index :categories, :column => :ancestry
    remove_column :categories, :ancestry
  end

  protected

    def choticimo(father, cat_id)
      meli_url = 'https://api.mercadolibre.com/categories/'
      faraday_request_get("#{meli_url}#{cat_id}")['children_categories'].each do |children_category|
        child = Category.create(meli_id: children_category['id'], name: children_category['name'], parent_id: father.id)
        grandchild_count = faraday_request_get("#{meli_url}#{children_category['id']}")['children_categories'].count
        if grandchild_count > 0
          choticimo(child, children_category['id'])
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
end
