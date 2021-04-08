class AddMessageIdentifierToGupshupWhatsappMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :gupshup_whatsapp_messages, :message_identifier, :string
    add_column :karix_whatsapp_messages, :message_identifier, :string
  end

  def down
    remove_column :gupshup_whatsapp_messages, :message_identifier, :string
    remove_column :karix_whatsapp_messages, :message_identifier, :string
  end
end
