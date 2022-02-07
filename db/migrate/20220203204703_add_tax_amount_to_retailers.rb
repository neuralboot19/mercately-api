class AddTaxAmountToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :tax_amount, :decimal, precision: 10, scale: 2, default: 0
  end
end
