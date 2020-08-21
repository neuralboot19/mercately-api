class AddTeamAssignmentToAgentCustomer < ActiveRecord::Migration[5.2]
  def up
    add_reference :agent_customers, :team_assignment
  end

  def down
    remove_reference :agent_customers, :team_assignment
  end
end
