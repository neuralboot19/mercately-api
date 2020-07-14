class AddIntChargesToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :int_charges, :boolean, default: false
    rename_column :retailers, :only_ec_charges, :ecu_charges
  end
end
