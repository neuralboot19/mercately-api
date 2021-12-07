class AddMainToPaymentMethods < ActiveRecord::Migration[5.2]
  def up
    add_column :payment_methods, :main, :boolean, default: false
    add_column :payment_methods, :deleted, :boolean, default: false
  end

  def down
    remove_column :payment_methods, :main, :boolean
    remove_column :payment_methods, :deleted, :boolean
  end
end
