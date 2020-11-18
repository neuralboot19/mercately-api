class CreateCustomerRelatedData < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_related_data do |t|
      t.references :customer_related_field
      t.references :customer
      t.string :data

      t.timestamps
    end
  end
end
