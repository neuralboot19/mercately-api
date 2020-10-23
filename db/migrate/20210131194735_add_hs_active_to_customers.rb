class AddHsActiveToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :hs_active, :boolean
    add_column :customers, :hs_id, :string
  end
end
