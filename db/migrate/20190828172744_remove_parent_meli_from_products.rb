class RemoveParentMeliFromProducts < ActiveRecord::Migration[5.2]
  def up
    remove_column :products, :parent_meli_id, :string
  end

  def down
    add_column :products, :parent_meli_id, :string
  end
end
