class CreateChatBotCustomer < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_bot_customers do |t|
      t.references :customer
      t.references :chat_bot

      t.timestamps
    end
  end
end
