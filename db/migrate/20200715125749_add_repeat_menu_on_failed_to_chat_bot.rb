class AddRepeatMenuOnFailedToChatBot < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bots, :repeat_menu_on_failure, :boolean, default: false
  end

  def down
    remove_column :chat_bots, :repeat_menu_on_failure, :boolean
  end
end
