class AddIndexToCategories < ActiveRecord::Migration[5.2]
  def up
    add_index :categories, :meli_id, unique: true, where: 'meli_id IS NOT NULL'
  end

  def down
    remove_index :categories, :meli_id
  end
end
