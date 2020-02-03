class RemoveKarixWhatsAppPhoneFromCustomers < ActiveRecord::Migration[5.2]
  def up
    if Customer.column_names.include?('karix_whatsapp_phone')
      Customer.where.not(karix_whatsapp_phone: nil).each do |c|
        c.update_column(:phone, c.karix_whatsapp_phone)
      end

      remove_column :customers, :karix_whatsapp_phone, :string
    end
  end

  def down
    add_column :customers, :karix_whatsapp_phone, :string
  end
end
