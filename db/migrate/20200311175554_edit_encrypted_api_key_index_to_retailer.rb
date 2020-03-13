class EditEncryptedApiKeyIndexToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :encrypted_api_key_salt, :string

    remove_index :retailers, :encrypted_api_key
    add_index :retailers, :encrypted_api_key, unique: false
  end
end
