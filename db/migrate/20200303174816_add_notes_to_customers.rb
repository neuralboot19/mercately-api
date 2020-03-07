class AddNotesToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :notes, :text
  end
end
