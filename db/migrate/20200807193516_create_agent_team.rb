class CreateAgentTeam < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_teams do |t|
      t.references :team_assignment
      t.references :retailer_user
      t.integer :max_assignments, default: 0
      t.integer :assigned_amount, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
