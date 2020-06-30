class CreatePaymentMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_methods do |t|
      t.string :stripe_pm_id, null: false
      t.belongs_to :retailer, foreign_key: true
      t.string :payment_type, null: false
      t.json :payment_payload, null: false

      t.timestamps
    end
  end
end
