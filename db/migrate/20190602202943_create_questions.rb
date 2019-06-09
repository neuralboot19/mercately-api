class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :product, foreign_key: true
      t.string :answer
      t.string :question
      t.string :meli_id

      t.timestamps
    end
  end
end
