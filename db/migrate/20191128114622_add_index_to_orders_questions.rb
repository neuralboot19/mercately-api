class AddIndexToOrdersQuestions < ActiveRecord::Migration[5.2]
  def up
    add_index :orders, :meli_order_id, unique: true
    add_index :questions, :meli_id, unique: true
  end

  def down
    remove_index :orders, :meli_order_id
    remove_index :questions, :meli_id
  end
end
