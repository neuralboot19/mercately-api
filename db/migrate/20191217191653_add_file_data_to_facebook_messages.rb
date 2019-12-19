class AddFileDataToFacebookMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_messages, :file_data, :string
  end
end
