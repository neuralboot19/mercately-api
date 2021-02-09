class CreateCustomerHubspotFields < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_hubspot_fields do |t|
      t.string :customer_field
      t.references :hubspot_field, foreign_key: true
      t.references :retailer, foreign_key: true

      t.index [:customer_field, :hubspot_field_id, :retailer_id], name: 'chf_customer_field_husbpot_field_retailer', unique: true
      t.timestamps
    end
  end
end
