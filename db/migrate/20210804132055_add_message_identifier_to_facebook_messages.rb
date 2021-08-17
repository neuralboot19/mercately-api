class AddMessageIdentifierToFacebookMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :facebook_messages, :message_identifier, :string
  end

  def down
    remove_column :facebook_messages, :message_identifier, :string
  end
end
