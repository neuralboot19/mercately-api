class AddCountUnreadMessagesToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :count_unread_messages, :integer, default: 0
  end

  def down
    remove_column :customers, :count_unread_messages, :integer
  end
end
