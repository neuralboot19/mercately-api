class AddAppVersionRetailerUser < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :app_version, :string
  end
end
