class AddMessageTypeToKarixWhatsappMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :karix_whatsapp_messages, :message_type, :string
  end

  def down
    remove_column :karix_whatsapp_messages, :message_type, :string
  end
end
