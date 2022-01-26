class AddDeleteAssetsToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :delete_assets, :boolean, default: true
  end

  def down
    remove_column :retailers, :delete_assets, :boolean
  end
end
