class AddOptionDeletedToChatBotOption < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bot_options, :option_deleted, :boolean, default: false
  end

  def down
    remove_column :chat_bot_options, :option_deleted, :boolean
  end
end
