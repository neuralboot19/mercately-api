class UpdateValidCustomerInCustomers < ActiveRecord::Migration[5.2]
  def change
    Customer.where.not(whatsapp_name: nil).update_all(valid_customer: true)
  end
end
