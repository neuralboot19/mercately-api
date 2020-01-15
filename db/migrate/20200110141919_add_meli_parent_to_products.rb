class AddMeliParentToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :meli_parent, :jsonb, default: []
  end

  def down
    remove_column :products, :meli_parent, :jsonb
  end
end
