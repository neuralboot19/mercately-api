class AddMonthIntervalToStripeTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :stripe_transactions, :month_interval, :integer, default: 0, null: false
    add_column :stripe_transactions, :web_id, :string
    add_column :paymentez_transactions, :month_interval, :integer, default: 0, null: false
    add_column :paymentez_transactions, :web_id, :string
  end
end
