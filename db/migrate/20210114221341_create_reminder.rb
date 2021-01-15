class CreateReminder < ActiveRecord::Migration[5.2]
  def change
    create_table :reminders do |t|
      t.references :retailer
      t.references :customer
      t.references :retailer_user
      t.references :whatsapp_template
      t.references :gupshup_whatsapp_message
      t.references :karix_whatsapp_message
      t.jsonb :content_params
      t.datetime :send_at
      t.datetime :send_at_timezone
      t.string :timezone
      t.string :web_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
