class AddDeletedToTags < ActiveRecord::Migration[5.2]
  def up
    add_column :tags, :deleted, :boolean
    change_column_default :tags, :deleted, false
  end

  def down
    remove_column :tags, :deleted, :boolean
  end
end
