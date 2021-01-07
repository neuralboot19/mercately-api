class AddSubmittedToGsTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :gs_templates, :submitted, :boolean, default: false
  end
end
