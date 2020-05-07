class CreateGupshupWhatsappMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :gupshup_whatsapp_messages do |t|
      t.belongs_to :retailer, foreign_key: true
      t.belongs_to :customer, foreign_key: true
      t.string :whatsapp_message_id, index: true
      t.string :gupshup_message_id, index: true
      t.integer :status, null: false
      t.string :direction, null: false
      t.json :message_payload
      t.string :source, null: false
      t.string :destination, null: false
      t.string :channel, null: false
      t.datetime :sent_at
      t.datetime :delivered_at
      t.datetime :read_at
      t.boolean :error
      t.json :error_payload

      t.timestamps
    end
  end
end
