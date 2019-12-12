class AddRemovedFromTeamToRetailerUser < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :removed_from_team, :boolean, default: false
  end
end
