class AddPlatformToTeamAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :team_assignments, :whatsapp, :boolean, default: false, null: false
    add_column :team_assignments, :messenger, :boolean, default: false, null: false
    add_column :team_assignments, :instagram, :boolean, default: false, null: false
  end
end
