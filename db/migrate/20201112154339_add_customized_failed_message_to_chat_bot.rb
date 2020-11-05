class AddCustomizedFailedMessageToChatBot < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bots, :on_failed_attempt, :integer
    add_column :chat_bots, :on_failed_attempt_message, :string

    ChatBot.where(repeat_menu_on_failure: true).update_all(on_failed_attempt: 0)
  end

  def down
    remove_column :chat_bots, :on_failed_attempt, :integer
    remove_column :chat_bots, :on_failed_attempt_message, :string
  end
end
