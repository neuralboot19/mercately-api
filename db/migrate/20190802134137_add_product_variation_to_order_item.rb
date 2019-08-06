class AddProductVariationToOrderItem < ActiveRecord::Migration[5.2]
  def up
    add_reference :order_items, :product_variation
  end

  def down
    remove_reference :order_items, :product_variation
  end
end
