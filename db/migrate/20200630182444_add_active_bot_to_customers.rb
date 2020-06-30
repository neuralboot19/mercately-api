class AddActiveBotToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :active_bot, :boolean, default: false
  end

  def down
    remove_column :customers, :active_bot, :boolean
  end
end
