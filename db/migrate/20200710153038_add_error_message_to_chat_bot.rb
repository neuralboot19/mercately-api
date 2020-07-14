class AddErrorMessageToChatBot < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bots, :error_message, :string
  end

  def down
    remove_column :chat_bots, :error_message, :string
  end
end
