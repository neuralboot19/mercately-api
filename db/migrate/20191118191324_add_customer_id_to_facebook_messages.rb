class AddCustomerIdToFacebookMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :facebook_messages, :customer, foreign_key: true
  end
end
