class AddRetailerIdToKarixWhatsappMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :karix_whatsapp_messages, :retailer, foreign_key: true
  end
end
