class AddTypeToQuestions < ActiveRecord::Migration[5.2]
  def up
    add_column :questions, :meli_question_type, :integer
  end

  def down
    remove_column :questions, :meli_question_type, :integer
  end
end
