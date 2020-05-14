class AddWhatsappNameToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :whatsapp_name, :string
  end
end
