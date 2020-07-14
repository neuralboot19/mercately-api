class CreateChatBot < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_bots do |t|
      t.references :retailer
      t.string :name
      t.string :trigger
      t.integer :failed_attempts
      t.string :goodbye_message
      t.boolean :any_interaction, default: false
      t.string :web_id
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
