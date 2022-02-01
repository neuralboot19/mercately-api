class CreateCountryConversation < ActiveRecord::Migration[5.2]
  def change
    create_table :country_conversations do |t|
      t.references :retailer_whatsapp_conversation, index: { name: 'index_country_conversations_by_date' }
      t.string :country_code
      t.integer :total_uic, default: 0
      t.integer :total_bic, default: 0
      t.float :total_cost_uic, default: 0.0
      t.float :total_cost_bic, default: 0.0

      t.index [:retailer_whatsapp_conversation_id, :country_code], unique: true, name: 'index_country_conversations_by_country'

      t.timestamps
    end
  end
end
