class AddInstagramUidToFacebookRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_retailers, :instagram_uid, :string
  end
end
