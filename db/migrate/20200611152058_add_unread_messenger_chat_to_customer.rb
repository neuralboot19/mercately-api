class AddUnreadMessengerChatToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :unread_messenger_chat, :boolean, default: false
    rename_column :customers, :unread_chat, :unread_whatsapp_chat
  end
end
