class AddHasFunnelsToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :has_funnels, :boolean, default: false
  end
end
