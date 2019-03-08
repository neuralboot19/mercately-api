class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :title
      t.string :category_id
      t.decimal :price
      t.integer :available_quantity
      t.string :buying_mode
      t.string :condition
      t.text :description
      t.references :retailer

      t.timestamps
    end
  end
end
