class CreateCustomerRelatedField < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_related_fields do |t|
      t.references :retailer
      t.string :name
      t.string :identifier
      t.integer :field_type, default: 0
      t.string :web_id

      t.timestamps
    end
  end
end
