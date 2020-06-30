class CreateChatBotOption < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_bot_options do |t|
      t.references :chat_bot
      t.string :text
      t.string :ancestry
      t.integer :position
      t.string :answer
      t.string :header_text

      t.timestamps
    end

    add_index :chat_bot_options, :ancestry
  end
end
