class AddIndexToKarixWhatsappMessage < ActiveRecord::Migration[5.2]
  def up
    add_index :karix_whatsapp_messages, :uid, unique: true
  end

  def down
    remove_index :karix_whatsapp_messages, :uid
  end
end
