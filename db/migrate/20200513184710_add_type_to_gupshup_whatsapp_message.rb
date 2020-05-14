class AddTypeToGupshupWhatsappMessage < ActiveRecord::Migration[5.2]
  def up
    add_column :gupshup_whatsapp_messages, :message_type, :string

    GupshupWhatsappMessage.update_all("message_type = CASE
                                                        WHEN message_payload->>'isHSM' = 'true'
                                                        THEN 'notification'
                                                        ELSE 'conversation'
                                                        END"
                                      )
  end

  def down
    remove_column :gupshup_whatsapp_messages, :message_type
  end
end
