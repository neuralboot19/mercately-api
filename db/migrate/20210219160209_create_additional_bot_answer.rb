class CreateAdditionalBotAnswer < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_bot_answers do |t|
      t.references :chat_bot_option
      t.string :text

      t.timestamps
    end
  end
end
