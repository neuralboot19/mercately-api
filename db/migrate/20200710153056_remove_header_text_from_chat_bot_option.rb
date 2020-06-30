class RemoveHeaderTextFromChatBotOption < ActiveRecord::Migration[5.2]
  def up
    remove_column :chat_bot_options, :header_text, :string
  end

  def down
    add_column :chat_bot_options, :header_text, :string
  end
end
