class AddEncryptedApiKeyIvToRetailer < ActiveRecord::Migration[5.2]
  def change
    change_column :retailers, :encripted_api_key, :string
    rename_column :retailers, :encripted_api_key, :encrypted_api_key
    add_column :retailers, :encrypted_api_key_iv, :string
  end
end
