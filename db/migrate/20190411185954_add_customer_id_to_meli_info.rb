class AddCustomerIdToMeliInfo < ActiveRecord::Migration[5.2]
  def change
    add_reference :meli_infos, :customer
  end
end
