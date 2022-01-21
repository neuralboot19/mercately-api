class AddBlockedToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :blocked, :boolean, default: false
  end

  def down
    remove_column :customers, :blocked, :boolean
  end
end
