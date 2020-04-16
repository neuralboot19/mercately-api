class CreateTopUp < ActiveRecord::Migration[5.2]
  def change
    create_table :top_ups do |t|
      t.references :retailer
      t.float :amount, default: 0

      t.timestamps
    end
  end
end
