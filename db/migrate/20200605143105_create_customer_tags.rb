class CreateCustomerTags < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_tags do |t|
      t.references :tag
      t.references :customer

      t.timestamps
    end
  end
end
