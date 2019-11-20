class AddCodeToProduct < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :code, :string
    add_index :products, [:retailer_id, :code], unique: true
  end

  def down
    remove_column :products, :code, :string
  end
end
