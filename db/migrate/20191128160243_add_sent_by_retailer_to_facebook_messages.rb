class AddSentByRetailerToFacebookMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_messages, :sent_by_retailer, :boolean, default: false
  end
end
