class AddMessengerIntegratedToFacebookRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_retailers, :messenger_integrated, :boolean, default: false
  end
end
