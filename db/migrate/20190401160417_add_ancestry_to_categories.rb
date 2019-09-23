class AddAncestryToCategories < ActiveRecord::Migration[5.2]
  def up
    add_column :categories, :ancestry, :string
    add_index :categories, :ancestry
  end

  def down
    remove_index :categories, :column => :ancestry
    remove_column :categories, :ancestry
  end
end
