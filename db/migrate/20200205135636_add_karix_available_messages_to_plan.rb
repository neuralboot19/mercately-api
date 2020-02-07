class AddKarixAvailableMessagesToPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :karix_available_messages, :integer, default: 0
    add_column :payment_plans, :karix_available_notifications, :integer, default: 0
  end
end
