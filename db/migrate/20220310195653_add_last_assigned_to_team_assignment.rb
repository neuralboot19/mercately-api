class AddLastAssignedToTeamAssignment < ActiveRecord::Migration[5.2]
  def up
    add_column :team_assignments, :last_assigned, :bigint
  end

  def down
    remove_column :team_assignments, :last_assigned, :bigint
  end
end
