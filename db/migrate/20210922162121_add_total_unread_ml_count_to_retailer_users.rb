class AddTotalUnreadMlCountToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :total_unread_ml_count, :integer, default: 0, null: false
  end
end
