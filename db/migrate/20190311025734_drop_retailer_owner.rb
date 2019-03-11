class DropRetailerOwner < ActiveRecord::Migration[5.2]
  def change
    drop_table :retailer_owners 
    drop_table :retailers
  end
end
