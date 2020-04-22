class CreateMobileTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :mobile_tokens do |t|
      t.belongs_to :retailer_user, foreign_key: true
      t.string :device
      t.string :encrypted_token
      t.string :encrypted_token_iv
      t.string :encrypted_token_salt
      t.datetime :expiration

      t.timestamps
    end

    add_index :mobile_tokens, [:device, :retailer_user_id], unique: true
  end
end
