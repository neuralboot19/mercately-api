class CreateKarixWhatsappMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :karix_whatsapp_messages do |t|
      t.string :uid
      t.string :account_uid
      t.string :source
      t.string :destination
      t.string :country
      t.string :content_type
      t.string :content_text
      t.string :content_media_url
      t.string :content_media_caption
      t.string :content_media_type
      t.string :content_location_longitude
      t.string :content_location_latitude
      t.string :content_location_label
      t.string :content_location_address
      t.datetime :created_time
      t.datetime :sent_time
      t.datetime :delivered_time
      t.datetime :updated_time
      t.string :status
      t.string :channel
      t.string :direction
      t.string :error_code
      t.string :error_message

      t.timestamps
    end
  end
end
