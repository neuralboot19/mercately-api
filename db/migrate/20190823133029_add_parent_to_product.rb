class AddParentToProduct < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :parent_meli_id, :string
    add_index :products, :parent_meli_id, unique: true
  end

  def down
    remove_column :products, :parent_meli_id, :string
  end
end
