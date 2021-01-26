class AddSkipOptionToChatBotOption < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bot_options, :skip_option, :boolean, default: false
  end

  def down
    remove_column :chat_bot_options, :skip_option, :boolean
  end
end
