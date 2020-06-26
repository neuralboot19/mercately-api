class AddSalesChannelToOrder < ActiveRecord::Migration[5.2]
  def up
    add_reference :orders, :sales_channel
  end

  def down
    remove_reference :orders, :sales_channel
  end
end
