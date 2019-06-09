class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.string :title
      t.text :answer
      t.references :retailer

      t.timestamps
    end
  end
end
