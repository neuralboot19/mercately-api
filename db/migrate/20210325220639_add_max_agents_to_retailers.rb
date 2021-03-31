class AddMaxAgentsToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :max_agents, :integer, default: 2
  end

  def down
    remove_column :retailers, :max_agents, :integer
  end
end
