class AddAllCustomersHsIntegratedToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :all_customers_hs_integrated, :boolean, default: true
  end
end
