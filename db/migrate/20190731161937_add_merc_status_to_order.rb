class AddMercStatusToOrder < ActiveRecord::Migration[5.2]
  def up
    add_column :orders, :merc_status, :integer, default: 0
  end

  def down
    remove_column :orders, :merc_status, :integer, default: 0
  end
end
