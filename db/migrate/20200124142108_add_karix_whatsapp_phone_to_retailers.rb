class AddKarixWhatsappPhoneToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :karix_whatsapp_phone, :string
  end

  def down
    remove_column :retailers, :karix_whatsapp_phone, :string
  end
end
