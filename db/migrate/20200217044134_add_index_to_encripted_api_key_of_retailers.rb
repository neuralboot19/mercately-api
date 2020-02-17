class AddIndexToEncriptedApiKeyOfRetailers < ActiveRecord::Migration[5.2]
  def up
    add_index :retailers, :encripted_api_key, unique: true
  end

  def down
    remove_index :customers, :encripted_api_key
  end
end
