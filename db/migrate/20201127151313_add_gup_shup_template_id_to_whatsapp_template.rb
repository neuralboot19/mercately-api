class AddGupShupTemplateIdToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def up
    add_column :whatsapp_templates, :gupshup_template_id, :string
  end

  def down
    remove_column :whatsapp_templates, :gupshup_template_id, :string
  end
end
