class AddNotesToOrders < ActiveRecord::Migration[5.2]
  def up
    add_column :orders, :notes, :text
  end

  def down
    remove_column :orders, :notes, :text
  end
end
