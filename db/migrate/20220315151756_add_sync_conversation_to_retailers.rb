class AddSyncConversationToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :hs_sync_conversation, :boolean, default: false
    add_column :retailers, :hs_conversacion_sync_time, :integer, default: 4
    add_column :retailers, :hs_next_sync, :datetime, default: 4.hours.from_now
  end
end