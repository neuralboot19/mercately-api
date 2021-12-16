class CreateRetailerAmountMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_amount_messages do |t|
      t.references :retailer, foreign_key: true, null: false
      t.date :calculation_date
      t.integer :ws_inbound, default: 0
      t.integer :ws_outbound, default: 0
      t.integer :total_ws_messages, default: 0
      t.integer :msn_inbound, default: 0
      t.integer :msn_outbound, default: 0
      t.integer :total_msn_messages, default: 0
      t.integer :ig_inbound, default: 0
      t.integer :ig_outbound, default: 0
      t.integer :total_ig_messages, default: 0
      t.integer :ml_inbound, default: 0
      t.integer :ml_outbound, default: 0
      t.integer :total_ml_messages, default: 0
      t.references :retailer_user, foreign_key: true

      t.timestamps
    end
  end
end