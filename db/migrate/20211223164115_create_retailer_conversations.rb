class CreateRetailerConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_conversations do |t|
      t.references :retailer, foreign_key: true, null: false
      t.references :retailer_user
      t.integer :new_conversations, default: 0
      t.integer :recurring_conversations, default: 0
      t.integer :platform
      t.date :calculation_date

      t.timestamps
    end
  end
end