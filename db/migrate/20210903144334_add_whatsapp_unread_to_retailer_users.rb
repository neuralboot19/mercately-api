class AddWhatsappUnreadToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :whatsapp_unread, :boolean, default: false
    add_column :retailer_users, :ml_unread, :boolean, default: false
    add_column :retailer_users, :messenger_unread, :boolean, default: false
    add_column :retailer_users, :instagram_unread, :boolean, default: false
  end
end
