class AddEncriptedApiKeyAndLastApiModifiedToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :encripted_api_key, :string, unique: true
    add_column :retailers, :last_api_key_modified_date, :datetime
  end
end
