class AddUnreadWhatsappChatsCountToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :unread_whatsapp_chats_count, :integer, default: 0, null: false
    add_column :retailer_users, :unread_messenger_chats_count, :integer, default: 0, null: false
    add_column :retailer_users, :unread_instagram_chats_count, :integer, default: 0, null: false
    add_column :retailer_users, :unread_ml_chats_count, :integer, default: 0, null: false
    add_column :retailer_users, :unread_ml_questions_count, :integer, default: 0, null: false
  end
end
