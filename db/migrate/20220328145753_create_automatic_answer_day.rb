class CreateAutomaticAnswerDay < ActiveRecord::Migration[5.2]
  def change
    create_table :automatic_answer_days do |t|
      t.references :automatic_answer
      t.integer :day, null: false
      t.boolean :all_day, default: false
      t.integer :start_time
      t.integer :end_time

      t.timestamps
    end
  end
end
