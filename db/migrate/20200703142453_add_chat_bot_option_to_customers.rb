class AddChatBotOptionToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_reference :customers, :chat_bot_option
  end

  def down
    remove_reference :customers, :chat_bot_option
  end
end
