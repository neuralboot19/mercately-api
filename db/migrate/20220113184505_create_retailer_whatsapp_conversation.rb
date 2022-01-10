class CreateRetailerWhatsappConversation < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_whatsapp_conversations do |t|
      t.references :retailer
      t.integer :year
      t.integer :month
      t.integer :free_uic_total, default: 0
      t.integer :free_bic_total, default: 0
      t.integer :free_point_total, default: 0
      t.integer :user_initiated_total, default: 0
      t.integer :business_initiated_total, default: 0
      t.float :user_initiated_cost, default: 0.0
      t.float :business_initiated_cost, default: 0.0

      t.index [:retailer_id, :year, :month], unique: true, name: 'index_retailer_whatsapp_conversations_by_date'

      t.timestamps
    end
  end
end
