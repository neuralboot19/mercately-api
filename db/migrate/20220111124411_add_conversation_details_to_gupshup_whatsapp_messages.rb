class AddConversationDetailsToGupshupWhatsappMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :gupshup_whatsapp_messages, :initiate_conversation, :boolean, default: false
    add_column :gupshup_whatsapp_messages, :conversation_type, :integer
    add_column :gupshup_whatsapp_messages, :conversation_payload, :json
  end

  def down
    remove_column :gupshup_whatsapp_messages, :initiate_conversation, :boolean
    remove_column :gupshup_whatsapp_messages, :conversation_type, :integer
    remove_column :gupshup_whatsapp_messages, :conversation_payload, :json
  end
end
