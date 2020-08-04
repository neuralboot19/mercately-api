class CreatePaymentezTransaction < ActiveRecord::Migration[5.2]
  def change
    drop_table :paymentez_transactions, if_exists: true
    create_table :paymentez_transactions do |t|
      t.string :status
      t.string :payment_date
      t.decimal :amount
      t.string :authorization_code
      t.integer :installments
      t.string :dev_reference
      t.string :message
      t.string :carrier_code
      t.string :pt_id
      t.integer :status_detail
      t.string :transaction_reference
      t.belongs_to :retailer, foreign_key: true
      t.belongs_to :payment_plan, foreign_key: true
      t.belongs_to :paymentez_credit_card, foreign_key: true

      t.timestamps
    end
  end
end
