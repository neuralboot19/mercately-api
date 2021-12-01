class RemoveHasFunnelsFromRetailers < ActiveRecord::Migration[5.2]
  def change
    remove_column :retailers, :has_funnels, :boolean, default: false
  end
end
