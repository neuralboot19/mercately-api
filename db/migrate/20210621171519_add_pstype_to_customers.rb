class AddPstypeToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :pstype, :integer
  end
end
