class AddPsidToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :psid, :string
  end
end
