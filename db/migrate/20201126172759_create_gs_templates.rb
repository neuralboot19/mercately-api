class CreateGsTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :gs_templates do |t|
      t.integer :status, default: 0, null: false
      t.string :label
      t.integer :key, default: 0, null: false
      t.string :category
      t.text :text
      t.text :example
      t.string :language, default: 'spanish'

      t.timestamps
    end
  end
end
