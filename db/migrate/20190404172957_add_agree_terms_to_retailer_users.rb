class AddAgreeTermsToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :agree_terms, :boolean
  end
end
