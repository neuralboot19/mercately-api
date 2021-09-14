class AddReturnOptionsToChatBotOption < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bot_options, :go_past_option, :boolean, default: false
    add_column :chat_bot_options, :go_start_option, :boolean, default: false
  end

  def down
    remove_column :chat_bot_options, :go_past_option, :boolean
    remove_column :chat_bot_options, :go_start_option, :boolean
  end
end
