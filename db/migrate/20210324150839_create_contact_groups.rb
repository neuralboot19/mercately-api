class CreateContactGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_groups do |t|
      t.references :retailer, foreign_key: true
      t.string :name
      t.string :web_id, index: true

      t.timestamps
    end
  end
end
