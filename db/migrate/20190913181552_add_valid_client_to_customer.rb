class AddValidClientToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :valid_customer, :boolean, default: false
  end

  def down
    remove_column :customers, :valid_customer, :boolean
  end
end
