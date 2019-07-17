class ChangeCustomerRelationship < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :meli_customer_id, :integer
    remove_column :meli_customers, :customer_id, :integer
  end
end
