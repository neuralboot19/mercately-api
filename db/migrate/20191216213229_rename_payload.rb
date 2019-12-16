class RenamePayload < ActiveRecord::Migration[5.2]
  def change
    rename_column :facebook_messages, :type, :file_type
  end
end
