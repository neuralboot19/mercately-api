class AddRetailerNumberToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :retailer_number, :string
  end

  def down
    remove_column :retailers, :retailer_number, :string
  end
end
