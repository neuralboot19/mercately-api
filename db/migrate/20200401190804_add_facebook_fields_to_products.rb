class AddFacebookFieldsToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :facebook_product_id, :string
    add_column :products, :manufacturer_part_number, :string
    add_column :products, :gtin, :string
    add_column :products, :brand, :string

    add_index :products, :facebook_product_id, unique: true, where: 'facebook_product_id IS NOT NULL'
  end

  def down
    remove_column :products, :facebook_product_id, :string
    remove_column :products, :manufacturer_part_number, :string
    remove_column :products, :gtin, :string
    remove_column :products, :brand, :string
  end
end
