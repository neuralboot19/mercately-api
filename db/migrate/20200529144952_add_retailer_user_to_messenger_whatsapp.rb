class AddRetailerUserToMessengerWhatsapp < ActiveRecord::Migration[5.2]
  def up
    add_reference :facebook_messages, :retailer_user
    add_reference :karix_whatsapp_messages, :retailer_user
    add_reference :gupshup_whatsapp_messages, :retailer_user
  end

  def down
    remove_reference :facebook_messages, :retailer_user
    remove_reference :karix_whatsapp_messages, :retailer_user
    remove_reference :gupshup_whatsapp_messages, :retailer_user
  end
end
