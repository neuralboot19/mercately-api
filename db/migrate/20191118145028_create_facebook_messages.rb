class CreateFacebookMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :facebook_messages do |t|
      t.string :uid
      t.string :id_client
      t.references :facebook_retailer, foreign_key: true
      t.text :text
      t.string :mid
      t.string :reply_to

      t.timestamps
    end
  end
end
