class AddWebhookDataToChatBotAction < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bot_actions, :webhook, :string
    add_column :chat_bot_actions, :action_event, :integer, default: 0
    add_column :chat_bot_actions, :username, :string
    add_column :chat_bot_actions, :password, :string
    add_column :chat_bot_actions, :payload_type, :integer, default: 0
    add_column :chat_bot_actions, :data, :jsonb, default: []
    add_column :chat_bot_actions, :headers, :jsonb, default: []
    add_column :chat_bot_actions, :classification, :integer, default: 0
    add_column :chat_bot_actions, :exit_message, :string
  end

  def down
    remove_column :chat_bot_actions, :webhook, :string
    remove_column :chat_bot_actions, :action_event, :integer
    remove_column :chat_bot_actions, :username, :string
    remove_column :chat_bot_actions, :password, :string
    remove_column :chat_bot_actions, :payload_type, :integer
    remove_column :chat_bot_actions, :data, :jsonb
    remove_column :chat_bot_actions, :headers, :jsonb
    remove_column :chat_bot_actions, :classification, :integer
    remove_column :chat_bot_actions, :exit_message, :string
  end
end
