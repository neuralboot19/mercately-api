class AddFilenameToFacebookMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :facebook_messages, :filename, :string
  end

  def down
    remove_column :facebook_messages, :filename, :string
  end
end
