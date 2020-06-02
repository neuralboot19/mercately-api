class AddUnreadChatFieldToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :unread_chat, :boolean, default: false
  end
end
