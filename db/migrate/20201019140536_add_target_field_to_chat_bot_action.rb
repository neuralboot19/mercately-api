class AddTargetFieldToChatBotAction < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bot_actions, :target_field, :string
  end

  def down
    remove_column :chat_bot_actions, :target_field, :string
  end
end
