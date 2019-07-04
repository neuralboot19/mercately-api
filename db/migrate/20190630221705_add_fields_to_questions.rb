class AddFieldsToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :deleted_from_listing, :boolean, default: false
    add_column :questions, :hold, :boolean, default: false
    add_column :questions, :status, :integer
  end
end
