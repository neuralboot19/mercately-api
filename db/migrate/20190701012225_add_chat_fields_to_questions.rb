class AddChatFieldsToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :date_read, :datetime
    add_column :questions, :site_id, :string
    add_column :questions, :sender_id, :integer
    add_reference :questions, :order
  end
end
