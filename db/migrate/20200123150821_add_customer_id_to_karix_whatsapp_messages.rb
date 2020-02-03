class AddCustomerIdToKarixWhatsappMessages < ActiveRecord::Migration[5.2]
  def up
    add_reference :karix_whatsapp_messages, :customer, foreign_key: true
  end

  def down
    remove_reference :karix_whatsapp_messages, :customer
  end
end
