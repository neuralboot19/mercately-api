class AddAgentToOrders < ActiveRecord::Migration[5.2]
  def up
    add_reference :orders, :retailer_user
  end

  def down
    remove_reference :orders, :retailer_user
  end
end
