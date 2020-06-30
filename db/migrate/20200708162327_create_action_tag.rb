class CreateActionTag < ActiveRecord::Migration[5.2]
  def change
    create_table :action_tags do |t|
      t.references :chat_bot_action
      t.references :tag

      t.timestamps
    end
  end
end
