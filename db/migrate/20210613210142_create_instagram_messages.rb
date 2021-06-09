class CreateInstagramMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :instagram_messages do |t|
      t.string :sender_uid
      t.string :id_client
      t.references :facebook_retailer, foreign_key: true
      t.text :text
      t.string :mid
      t.string :reply_to
      t.references :customer, foreign_key: true
      t.date :date_read
      t.boolean :sent_from_mercately
      t.boolean :sent_by_retailer
      t.string :file_type
      t.string :url
      t.string :file_data
      t.string :filename
      t.references :retailer_user, foreign_key: true
      t.string :sender_first_name
      t.string :sender_last_name
      t.string :sender_email

      t.timestamps
    end
  end
end
