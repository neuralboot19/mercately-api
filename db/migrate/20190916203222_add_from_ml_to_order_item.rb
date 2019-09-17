class AddFromMlToOrderItem < ActiveRecord::Migration[5.2]
  def up
    add_column :order_items, :from_ml, :boolean, default: false
  end

  def down
    remove_column :order_items, :from_ml, :boolean
  end
end
