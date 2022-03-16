class AddDescriptionToRetailers < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'uuid-ossp'
    add_column :retailers, :description, :text
    add_column :retailers, :country_code, :string
    add_column :retailers, :unique_key, :string, null: false, unique: true, default: -> { 'uuid_generate_v4()' }
    add_column :retailers, :catalog_slug, :string
  end
end
