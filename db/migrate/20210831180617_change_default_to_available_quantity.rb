class ChangeDefaultToAvailableQuantity < ActiveRecord::Migration[5.2]
  def up
    change_column_default :products, :available_quantity, 0
    Product.unscoped.where(available_quantity: nil).update_all(available_quantity: 0)
  end

  def down
    change_column_default :products, :available_quantity, nil
  end
end
