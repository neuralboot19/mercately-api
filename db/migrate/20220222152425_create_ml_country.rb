class CreateMlCountry < ActiveRecord::Migration[5.2]
  def change
    create_table :ml_countries do |t|
      t.string :name
      t.string :site
      t.string :domain

      t.timestamps
    end
  end
end
