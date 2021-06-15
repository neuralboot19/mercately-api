class CreateDeal < ActiveRecord::Migration[5.2]
  def change
    create_table :deals do |t|
      t.references :retailer, foreign_key: true
      t.references :funnel_step, foreign_key: true
      t.references :customer
      t.string :name
      t.string :web_id
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end
  end
end
