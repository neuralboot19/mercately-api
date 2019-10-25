class AddAnsweredToQuestions < ActiveRecord::Migration[5.2]
  def up
    add_column :questions, :answered, :boolean, default: false

    Question.where.not(answer: nil).update_all(answered: true)
  end

  def down
    remove_column :questions, :answered, :boolean
  end
end
