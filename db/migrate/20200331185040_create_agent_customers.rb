class CreateAgentCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_customers do |t|
      t.references :retailer_user, foreign_key: true, null: false
      t.references :customer, foreign_key: true, null: false

      t.timestamps
    end
  end
end
