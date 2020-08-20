class AddManageTeamAssignmentToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :manage_team_assignment, :boolean, default: false
  end

  def down
    remove_column :retailers, :manage_team_assignment, :boolean
  end
end
