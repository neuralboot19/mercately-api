class AddFeedbackDataToOrder < ActiveRecord::Migration[5.2]
  def up
    add_column :orders, :feedback_reason, :integer
    add_column :orders, :feedback_message, :string
    add_column :orders, :feedback_rating, :integer
  end

  def down
    remove_column :orders, :feedback_reason, :integer
    remove_column :orders, :feedback_message, :string
    remove_column :orders, :feedback_rating, :integer
  end
end
