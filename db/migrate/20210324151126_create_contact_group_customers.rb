class CreateContactGroupCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_group_customers do |t|
      t.references :contact_group, foreign_key: true
      t.references :customer, foreign_key: true

      t.timestamps
    end
  end
end
