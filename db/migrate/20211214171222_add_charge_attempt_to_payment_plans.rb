class AddChargeAttemptToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :charge_attempt, :integer, default: 0, null: false
  end
end
