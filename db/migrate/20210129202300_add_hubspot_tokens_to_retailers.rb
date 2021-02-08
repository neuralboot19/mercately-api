class AddHubspotTokensToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :hs_expires_in, :datetime
    add_column :retailers, :hs_access_token, :string
    add_column :retailers, :hs_refresh_token, :string
  end
end
