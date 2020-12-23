class AddWsCostsToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :ws_notification_cost, :float, default: 0.0672
  end
end
