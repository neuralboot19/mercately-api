class CreateTeamAssignment < ActiveRecord::Migration[5.2]
  def change
    create_table :team_assignments do |t|
      t.references :retailer
      t.string :name
      t.boolean :active_assignment, default: false
      t.boolean :default_assignment, default: false
      t.string :web_id

      t.timestamps
    end
  end
end
