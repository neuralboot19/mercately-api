class CreateBusinessRule < ActiveRecord::Migration[5.2]
  def change
    create_table :business_rules do |t|
      t.references :rule_category
      t.string :name
      t.text :description
      t.string :identifier

      t.timestamps
    end
  end
end
