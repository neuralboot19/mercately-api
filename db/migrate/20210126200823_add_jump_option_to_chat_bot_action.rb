class AddJumpOptionToChatBotAction < ActiveRecord::Migration[5.2]
  def up
    add_reference :chat_bot_actions, :jump_option, foreign_key: { to_table: :chat_bot_options }
  end

  def down
    remove_reference :chat_bot_actions, :jump_option
  end
end
