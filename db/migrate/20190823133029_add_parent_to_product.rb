class AddParentToProduct < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :parent_meli_id, :string, index: :unique
  end

  def down
    remove_column :products, :parent_meli_id, :string
    remove_index :products, :parent_meli_id
  end
end
