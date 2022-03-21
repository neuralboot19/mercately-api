class CreateRetailerBusinessRule < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_business_rules do |t|
      t.references :retailer
      t.references :business_rule

      t.timestamps
    end
  end
end
