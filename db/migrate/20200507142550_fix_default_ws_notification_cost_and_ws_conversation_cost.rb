class FixDefaultWsNotificationCostAndWsConversationCost < ActiveRecord::Migration[5.2]
  def up
    Retailer.all.each do |r|
      r.ws_notification_cost = 0.0672 if r.ws_notification_cost == 0.005
      r.ws_conversation_cost = 0.005  if r.ws_conversation_cost == 0.0672

      r.save!
    end

    change_column :retailers, :ws_notification_cost, :float, default: 0.0672
    change_column :retailers, :ws_conversation_cost, :float, default: 0.005
  end

  def down
    change_column :retailers, :ws_notification_cost, :float, default: 0.005
    change_column :retailers, :ws_conversation_cost, :float, default: 0.0672
  end
end
