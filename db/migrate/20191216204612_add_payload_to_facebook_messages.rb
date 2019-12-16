class AddPayloadToFacebookMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_messages, :type, :string
    add_column :facebook_messages, :url, :string
    rename_column :facebook_messages, :uid, :sender_uid
  end
end
