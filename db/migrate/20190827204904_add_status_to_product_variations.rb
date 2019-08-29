class AddStatusToProductVariations < ActiveRecord::Migration[5.2]
  def up
    add_column :product_variations, :status, :integer, default: 0
  end

  def down
    remove_column :product_variations, :status, :integer
  end
end
