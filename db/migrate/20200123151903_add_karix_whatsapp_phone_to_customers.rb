class AddKarixWhatsappPhoneToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :karix_whatsapp_phone, :string, unique: true
  end

  def down
    remove_column :customers, :karix_whatsapp_phone, :string
  end
end
