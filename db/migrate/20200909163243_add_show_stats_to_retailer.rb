class AddShowStatsToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :show_stats, :boolean, default: false
  end

  def down
    remove_column :retailers, :show_stats, :boolean
  end
end
