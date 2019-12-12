class AddRetailerAdminToRetailerUser < ActiveRecord::Migration[5.2]
  
  def up
    add_column :retailer_users, :retailer_admin, :boolean, default: true
    RetailerUser.update_all(retailer_admin: true)
  end

  def down 
    remove_column :retailer_users, :retailer_admin
  end
end
