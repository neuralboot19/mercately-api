class CustomerBelongsToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :retailer_id, :integer
    add_index :customers, :retailer_id
  end
end
