class ChangeDefaultValueToSomeProductColumns < ActiveRecord::Migration[5.2]
  def up
    change_column :products, :meli_status, :integer, default: nil
    change_column :products, :sold_quantity, :integer, default: 0

    Product.where(meli_product_id: nil).update_all(meli_status: nil)
    Product.where(sold_quantity: nil).update_all(sold_quantity: 0)
  end

  def down
    change_column :products, :meli_status, :integer, default: 0
    change_column :products, :sold_quantity, :integer, default: nil

    Product.where(meli_product_id: nil).update_all(meli_status: 0)
  end
end
