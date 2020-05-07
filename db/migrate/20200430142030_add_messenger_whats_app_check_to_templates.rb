class AddMessengerWhatsAppCheckToTemplates < ActiveRecord::Migration[5.2]
  def up
    add_column :templates, :enable_for_messenger, :boolean, default: false
    add_column :templates, :enable_for_whatsapp, :boolean, default: false
  end

  def down
    remove_column :templates, :enable_for_messenger, :boolean
    remove_column :templates, :enable_for_whatsapp, :boolean
  end
end
