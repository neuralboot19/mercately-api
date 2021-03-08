class AddPlatformToChatBot < ActiveRecord::Migration[5.2]
  def up
    add_column :chat_bots, :platform, :integer

    ChatBot.all.each do |cb|
      cb.update_column(:platform, :whatsapp)
    end
  end

  def down
    remove_column :chat_bots, :platform, :integer
  end
end
