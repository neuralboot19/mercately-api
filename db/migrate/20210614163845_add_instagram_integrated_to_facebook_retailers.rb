class AddInstagramIntegratedToFacebookRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_retailers, :instagram_integrated, :boolean, default: false
  end
end
