class AddEnableForInstagramToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :enable_for_instagram, :boolean, default: false
  end
end
