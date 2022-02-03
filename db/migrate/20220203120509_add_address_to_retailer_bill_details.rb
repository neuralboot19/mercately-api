class AddAddressToRetailerBillDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_bill_details, :business_address, :string
  end
end
