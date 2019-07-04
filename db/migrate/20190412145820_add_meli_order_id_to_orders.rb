class AddMeliOrderIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :meli_order_id, :string
  end
end
