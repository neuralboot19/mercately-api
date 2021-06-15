class CreateFunnelSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :funnel_steps do |t|
      t.references :funnel, foreign_key: true
      t.string :name
      t.integer :position
      t.decimal :step_total, precision: 10, scale: 2
      t.timestamps
    end
  end
end
