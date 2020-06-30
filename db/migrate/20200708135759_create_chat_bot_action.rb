class CreateChatBotAction < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_bot_actions do |t|
      t.references :chat_bot_option
      t.references :retailer_user
      t.integer :action_type

      t.timestamps
    end
  end
end
