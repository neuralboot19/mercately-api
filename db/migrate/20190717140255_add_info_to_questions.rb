class AddInfoToQuestions < ActiveRecord::Migration[5.2]
  def up
    add_column :questions, :answer_status, :integer
    add_column :questions, :date_created_question, :datetime
    add_column :questions, :date_created_answer, :datetime
  end

  def down
    remove_column :questions, :answer_status, :integer
    remove_column :questions, :date_created_question, :datetime
    remove_column :questions, :date_created_answer, :datetime
  end
end
