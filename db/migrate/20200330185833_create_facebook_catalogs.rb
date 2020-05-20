class CreateFacebookCatalogs < ActiveRecord::Migration[5.2]
  def change
    create_table :facebook_catalogs do |t|
      t.references :retailer, foreign_key: true
      t.string :uid
      t.string :name
      t.string :business_id

      t.timestamps
    end
  end
end
