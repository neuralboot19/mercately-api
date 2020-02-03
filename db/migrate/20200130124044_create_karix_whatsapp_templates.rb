class CreateKarixWhatsappTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :karix_whatsapp_templates do |t|
      t.references :retailer
      t.string :text
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
