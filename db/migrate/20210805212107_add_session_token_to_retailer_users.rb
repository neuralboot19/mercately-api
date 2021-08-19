class AddSessionTokenToRetailerUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailer_users, :api_session_token, :string
    add_column :retailer_users, :api_session_device, :string
    add_column :retailer_users, :api_session_expiration, :datetime
  end

  def down
    remove_column :retailer_users, :api_session_expiration
    remove_column :retailer_users, :api_session_device
    remove_column :retailer_users, :api_session_token
  end
end
