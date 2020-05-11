class RenameKarixWhatsappTemplateToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    rename_table :karix_whatsapp_templates, :whatsapp_templates
  end
end
