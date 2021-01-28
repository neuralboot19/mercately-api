class AddOnlyAssignedToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :only_assigned, :boolean, default: false
  end
end
