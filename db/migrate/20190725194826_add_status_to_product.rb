class AddStatusToProduct < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :status, :integer, default: 0
    add_column :products, :meli_status, :integer, default: 0
  end

  def down
    remove_column :products, :status, :integer, default: 0
    remove_column :products, :meli_status, :integer, default: 0
  end
end
