class AddTemplateTypeToWhatsappTemplates < ActiveRecord::Migration[5.2]
  def up
    add_column :whatsapp_templates, :template_type, :integer, default: 0, null: false
  end

  def down
    remove_column :whatsapp_templates, :template_type, :integer
  end
end
