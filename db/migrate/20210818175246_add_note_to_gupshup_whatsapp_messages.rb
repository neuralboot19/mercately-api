class AddNoteToGupshupWhatsappMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :gupshup_whatsapp_messages, :note, :boolean, default: false
    add_column :facebook_messages, :note, :boolean, default: false
    add_column :instagram_messages, :note, :boolean, default: false
  end
end
