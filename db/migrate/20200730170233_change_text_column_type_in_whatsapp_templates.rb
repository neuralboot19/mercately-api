class ChangeTextColumnTypeInWhatsappTemplates < ActiveRecord::Migration[5.2]
  def change
    change_column :whatsapp_templates, :text, :text, default: ''
  end
end
