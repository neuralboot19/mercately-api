class AddFreeTierToRetailerWsConversation < ActiveRecord::Migration[5.2]
  def up
    add_column :retailer_whatsapp_conversations, :free_tier_total, :integer, default: 0
  end

  def down
    remove_column :retailer_whatsapp_conversations, :free_tier_total, :integer
  end
end
