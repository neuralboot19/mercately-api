class AddOptionTypeToChatBotOption < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bot_options, :option_type, :integer, default: 0
  end

  def down
    remove_column :chat_bot_options, :option_type, :integer
  end
end
