class AddActiveToRetailerUser < ActiveRecord::Migration[5.2]
  def up
    add_column :retailer_users, :active, :boolean, default: true
  end

  def down
    remove_column :retailer_users, :active, :boolean
  end
end
