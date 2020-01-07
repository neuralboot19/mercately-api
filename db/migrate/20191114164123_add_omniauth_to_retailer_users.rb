class AddOmniauthToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :provider, :string
    add_column :retailer_users, :uid, :string
    add_column :retailer_users, :facebook_access_token, :string
    add_column :retailer_users, :facebook_access_token_expiration, :date
  end
end
