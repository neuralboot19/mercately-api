class AddHasDealsToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :has_deals, :boolean, default: false
  end
end
