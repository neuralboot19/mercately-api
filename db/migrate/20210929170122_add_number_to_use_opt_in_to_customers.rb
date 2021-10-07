class AddNumberToUseOptInToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :number_to_use_opt_in, :boolean, default: false, null: false
  end
end
