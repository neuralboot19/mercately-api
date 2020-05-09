class AddOptInDataToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :whatsapp_opt_in, :boolean, default: false
  end

  def down
    remove_column :customers, :whatsapp_opt_in, :boolean
  end
end
