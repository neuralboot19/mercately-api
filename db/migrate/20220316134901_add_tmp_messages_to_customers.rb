class AddTmpMessagesToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :tmp_messages, :jsonb, default: []
  end
end
