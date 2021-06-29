class AddAttachmentsToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :attachments, :jsonb, default: []
  end
end
