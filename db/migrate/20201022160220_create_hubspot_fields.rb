class CreateHubspotFields < ActiveRecord::Migration[5.2]
  def change
    create_table :hubspot_fields do |t|
      t.string :hubspot_field
      t.string :hubspot_label
      t.string :hubspot_type
      t.boolean :taken, default: false
      t.boolean :deleted, default: false
      t.references :retailer, foreign_key: true

      t.index [ :retailer_id, :hubspot_field ], unique: true
      t.timestamps
    end
  end
end
