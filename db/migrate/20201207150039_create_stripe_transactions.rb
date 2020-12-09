class CreateStripeTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_transactions do |t|
      t.integer :retailer_id
      t.string :stripe_id
      t.integer :amount
      t.references :payment_method

      t.timestamps
    end
  end
end
