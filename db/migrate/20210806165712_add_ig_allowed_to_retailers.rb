class AddIgAllowedToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :ig_allowed, :boolean, default: false
  end
end
