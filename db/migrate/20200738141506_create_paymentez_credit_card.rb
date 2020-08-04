class CreatePaymentezCreditCard < ActiveRecord::Migration[5.2]
  def change
    drop_table :paymentez_credit_cards, if_exists: true
    create_table :paymentez_credit_cards do |t|
      t.string :card_type
      t.string :number
      t.string :name
      t.belongs_to :retailer
      t.string :token
      t.string :status
      t.string :expiry_month
      t.string :expiry_year
      t.boolean :deleted, default: false
      t.boolean :main, default: false

      t.timestamps
    end
  end
end
