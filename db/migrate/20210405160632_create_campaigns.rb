class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :template_text
      t.integer :status, default: 0
      t.datetime :send_at
      t.jsonb :content_params
      t.references :whatsapp_template, foreign_key: true
      t.references :contact_group, foreign_key: true
      t.references :retailer, foreign_key: true
      t.string :web_id, index: true

      t.timestamps
    end
  end
end
