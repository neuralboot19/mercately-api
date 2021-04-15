class CreateDemoRequestLead < ActiveRecord::Migration[5.2]
  def change
    create_table :demo_request_leads do |t|
      t.string :name
      t.string :email
      t.string :company
      t.integer :employee_quantity
      t.string :country
      t.string :phone
      t.string :message
      t.string :problem_to_resolve
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
