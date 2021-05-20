class ChangeQuestionFieldType < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :question, :text
    change_column :questions, :answer, :text
  end
end
