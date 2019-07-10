class AddUniquenessToProducts < ActiveRecord::Migration[5.2]
  def up
    add_index :products, :meli_product_id, unique: true
    add_index :product_variations, :variation_meli_id, unique: true
  end

  def down
    remove_index :products, :meli_product_id
    add_index :products, :meli_product_id
    remove_index :product_variations, :variation_meli_id
    add_index :product_variations, :variation_meli_id
  end
end
