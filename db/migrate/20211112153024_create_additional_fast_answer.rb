class CreateAdditionalFastAnswer < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_fast_answers do |t|
      t.references :template
      t.text :answer
      t.string :file_type

      t.timestamps
    end
  end
end
