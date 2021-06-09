class AddRetailerUserToDeal < ActiveRecord::Migration[5.2]
  def change
    add_reference :deals, :retailer_user, index: true
  end
end
