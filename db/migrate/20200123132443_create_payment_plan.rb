class CreatePaymentPlan < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_plans do |t|
    	t.references :retailer, foreign_key: true
      t.decimal :price, default: 0
      t.date :start_date, default: -> { 'CURRENT_TIMESTAMP' }
      t.date :next_pay_date
      t.integer :status, default: 0
      t.integer :plan, default: 0
      t.timestamps
    end
  end
end
