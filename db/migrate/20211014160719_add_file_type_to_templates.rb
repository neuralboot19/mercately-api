class AddFileTypeToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :file_type, :string
  end
end
