class RemoveIgAllowedFromRetailers < ActiveRecord::Migration[5.2]
  def change
    remove_column :retailers, :ig_allowed, :boolean, default: false
  end
end
