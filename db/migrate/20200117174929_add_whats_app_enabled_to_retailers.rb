class AddWhatsAppEnabledToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :whats_app_enabled, :boolean, default: false
  end
end
