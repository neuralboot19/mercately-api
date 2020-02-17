class AddPackIdToOrders < ActiveRecord::Migration[5.2]
  def up
    add_column :orders, :pack_id, :string
  end

  def down
    remove_column :orders, :pack_id, :string
  end
end
