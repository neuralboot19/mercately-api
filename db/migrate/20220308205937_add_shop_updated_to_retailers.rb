class AddShopUpdatedToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :shop_updated, :boolean, default: false, null: false
  end
end
