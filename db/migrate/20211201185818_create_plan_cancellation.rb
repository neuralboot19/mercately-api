class CreatePlanCancellation < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_cancellations do |t|
      t.references :retailer
      t.integer :reason
      t.string :comment

      t.timestamps
    end
  end
end
