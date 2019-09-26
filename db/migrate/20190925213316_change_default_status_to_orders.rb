class ChangeDefaultStatusToOrders < ActiveRecord::Migration[5.2]
  def up
    change_column :orders, :status, :integer, default: 0

    Order.where(status: nil).update_all(status: 0)
  end

  def down
    change_column :orders, :status, :integer, default: nil
  end
end
