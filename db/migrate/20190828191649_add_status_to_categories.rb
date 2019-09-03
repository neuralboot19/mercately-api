class AddStatusToCategories < ActiveRecord::Migration[5.2]
  def up
    add_column :categories, :status, :integer, default: 0
  end

  def down
    remove_column :categories, :status, :integer
  end
end
