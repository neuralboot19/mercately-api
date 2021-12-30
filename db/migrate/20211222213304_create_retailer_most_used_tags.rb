class CreateRetailerMostUsedTags < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_most_used_tags do |t|
      t.references :retailer, foreign_key: true, null: false
      t.references :tag, foreign_key: true, null: false
      t.integer :amount_used, default: 0
      t.date :calculation_date

      t.timestamps
    end
  end
end
