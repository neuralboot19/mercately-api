class AddCampaignToGupshupWhatsappMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :gupshup_whatsapp_messages, :campaign
    add_reference :karix_whatsapp_messages, :campaign
  end
end
