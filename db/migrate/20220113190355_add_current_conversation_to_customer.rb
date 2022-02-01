class AddCurrentConversationToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :current_conversation, :string
    add_column :customers, :ws_uic_cost, :float
    add_column :customers, :ws_bic_cost, :float
  end

  def down
    remove_column :customers, :current_conversation, :string
    remove_column :customers, :ws_uic_cost, :float
    remove_column :customers, :ws_bic_cost, :float
  end
end
