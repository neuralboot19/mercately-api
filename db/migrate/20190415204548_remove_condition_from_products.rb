class RemoveConditionFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :condition, :string
    add_column :products, :condition, :integer, default: 0
  end
end
