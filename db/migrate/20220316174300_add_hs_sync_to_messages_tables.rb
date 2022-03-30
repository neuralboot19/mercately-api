class AddHsSyncToMessagesTables < ActiveRecord::Migration[5.2]
  def change
    add_column :gupshup_whatsapp_messages, :hs_sync, :boolean, default: false
    add_column :facebook_messages, :hs_sync, :boolean, default: false
    add_column :instagram_messages, :hs_sync, :boolean, default: false
  end
end
