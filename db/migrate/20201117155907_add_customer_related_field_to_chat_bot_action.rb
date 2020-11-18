class AddCustomerRelatedFieldToChatBotAction < ActiveRecord::Migration[5.2]
  def up
    add_reference :chat_bot_actions, :customer_related_field
  end

  def down
    remove_reference :chat_bot_actions, :customer_related_field
  end
end
