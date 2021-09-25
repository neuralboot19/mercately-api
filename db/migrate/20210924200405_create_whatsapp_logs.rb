class CreateWhatsappLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :whatsapp_logs do |t|
      t.jsonb :payload_sent
      t.jsonb :response
      t.string :error_message
      t.string :gupshup_message_id, index: true
      t.references :gupshup_whatsapp_message, foreign_key: true
      t.references :retailer, foreign_key: true

      t.timestamps
    end
  end
end
