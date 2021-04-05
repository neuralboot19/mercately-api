class ChangeReactivateAfterOnChatBot < ActiveRecord::Migration[5.2]
  def up
    change_column :chat_bots, :reactivate_after, :float
  end

  def down
    change_column :chat_bots, :reactivate_after, :integer
  end
end
