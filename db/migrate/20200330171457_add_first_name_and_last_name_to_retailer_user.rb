class AddFirstNameAndLastNameToRetailerUser < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :first_name, :string
    add_column :retailer_users, :last_name, :string
  end
end
