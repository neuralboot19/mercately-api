class CreateRetailerAverageResponseTime < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_average_response_times do |t|
      t.references :retailer, foreign_key: true
      t.references :retailer_user
      t.decimal :first_time_average
      t.decimal :conversation_time_average
      t.date :calculation_date
      t.integer :platform

      t.timestamps
    end
  end
end