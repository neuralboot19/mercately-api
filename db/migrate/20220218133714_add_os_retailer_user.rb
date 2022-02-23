class AddOsRetailerUser < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :mobile_type, :integer
  end
end
