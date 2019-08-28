class RemoveIndexesFromProductsAndVariations < ActiveRecord::Migration[5.2]
  def up
    remove_index :products, :meli_product_id
    remove_index :product_variations, :variation_meli_id
    remove_index :products, :parent_meli_id
  end

  def down
    add_index :products, :meli_product_id, unique: true
    add_index :product_variations, :variation_meli_id, unique: true
    add_index :products, :parent_meli_id, unique: true
  end
end
