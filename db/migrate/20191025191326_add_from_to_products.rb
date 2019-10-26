class AddFromToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :from, :integer, default: 0
  end
end
