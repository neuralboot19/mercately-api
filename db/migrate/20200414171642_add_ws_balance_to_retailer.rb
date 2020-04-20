class AddWsBalanceToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :ws_balance, :float, default: 0.0
    add_column :retailers, :ws_next_notification_balance, :float, default: 1.5
    add_column :retailers, :ws_notification_cost, :float, default: 0.0672
    add_column :retailers, :ws_conversation_cost, :float, default: 0.005
  end
end
