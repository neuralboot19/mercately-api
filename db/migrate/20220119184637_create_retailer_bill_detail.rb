class CreateRetailerBillDetail < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_bill_details do |t|
      t.references :retailer
      t.string :business_name
      t.string :identification_type
      t.string :identification_number
      t.string :business_phone
      t.string :business_email
      t.string :iva_description

      t.timestamps
    end
  end
end
