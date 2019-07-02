class AddFieldsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :currency_id, :string
    add_column :orders, :total_amount, :float
    add_column :orders, :date_closed, :datetime
  end
end
