class AddTemplateToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :template, :jsonb, default: []
  end
end
