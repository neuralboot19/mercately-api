class CreateFunnel < ActiveRecord::Migration[5.2]
  def change
    create_table :funnels do |t|
      t.references :retailer, foreign_key: true
      t.string :name
      t.timestamps
    end
  end
end
