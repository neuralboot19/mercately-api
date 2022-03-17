class MakeCatalogSlugUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :retailers, :catalog_slug, unique: true
  end
end
