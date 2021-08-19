class AddStatusChatToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :status_chat, :integer, default: 0
    add_index :customers, :status_chat
  end

  def down
    remove_column :customers, :status_chat, :integer
  end
end
