class AddMessageIdentifierToInstagramMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :instagram_messages, :message_identifier, :string
  end
end
