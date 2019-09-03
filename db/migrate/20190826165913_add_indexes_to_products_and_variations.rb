class AddIndexesToProductsAndVariations < ActiveRecord::Migration[5.2]
  def up
    add_index :products, :meli_product_id, unique: true, where: 'meli_product_id IS NOT NULL'
    add_index :product_variations, :variation_meli_id, unique: true, where: 'variation_meli_id IS NOT NULL'
    add_index :products, :parent_meli_id, unique: true, where: 'parent_meli_id IS NOT NULL'
  end

  def down
    remove_index :products, :meli_product_id
    remove_index :product_variations, :variation_meli_id
    remove_index :products, :parent_meli_id
  end
end
