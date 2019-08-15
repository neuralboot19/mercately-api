class AddTagsToTemplate < ActiveRecord::Migration[5.2]
  def up
    add_column :templates, :enable_for_questions, :boolean, default: false
    add_column :templates, :enable_for_chats, :boolean, default: false
  end

  def down
    remove_column :templates, :enable_for_questions, :boolean, default: false
    remove_column :templates, :enable_for_chats, :boolean, default: false
  end
end
