class AddOnlyEcChargesToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :only_ec_charges, :boolean, default: false
  end
end
