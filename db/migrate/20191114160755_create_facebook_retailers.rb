class CreateFacebookRetailers < ActiveRecord::Migration[5.2]
  def change
    create_table :facebook_retailers do |t|
      t.references :retailer, foreign_key: true
      t.string :uid
      t.string :access_token

      t.timestamps
    end
  end
end
