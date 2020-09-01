class AddRetailerSupervisorToRetailerUser < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :retailer_supervisor, :boolean, default: false
  end
end
