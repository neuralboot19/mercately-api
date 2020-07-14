class AddAllowBotsToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :allow_bots, :boolean, default: false
  end

  def down
    remove_column :retailers, :allow_bots, :boolean
  end
end
