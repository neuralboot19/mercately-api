class AddWsMsnInteractionsDataToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :ws_active, :boolean, default: false
    add_column :customers, :last_chat_interaction, :datetime

    add_index :customers, :last_chat_interaction
    add_index :customers, :ws_active
    add_index :customers, :psid
  end

  def down
    remove_column :customers, :ws_active, :boolean
    remove_column :customers, :last_chat_interaction, :datetime
    remove_index :customers, :psid
  end
end
