class AddMonthIntervalToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :month_interval, :integer, default: 1
  end
end
