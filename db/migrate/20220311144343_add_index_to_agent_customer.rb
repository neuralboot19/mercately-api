class AddIndexToAgentCustomer < ActiveRecord::Migration[5.2]
  def up
    add_index :agent_customers, [:retailer_user_id, :customer_id], unique: true, where: "team_assignment_id IS NOT NULL"
  end

  def down
    remove_index :agent_customers, [:retailer_user_id, :customer_id]
  end
end
