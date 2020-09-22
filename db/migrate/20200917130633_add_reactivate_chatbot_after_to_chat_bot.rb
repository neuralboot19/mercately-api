class AddReactivateChatbotAfterToChatBot < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_bots, :reactivate_after, :integer, null: true
  end
end
