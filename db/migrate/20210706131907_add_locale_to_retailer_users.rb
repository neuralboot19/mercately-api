class AddLocaleToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :locale, :integer, default: 0
  end
end
