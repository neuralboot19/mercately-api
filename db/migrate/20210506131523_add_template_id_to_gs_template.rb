class AddTemplateIdToGsTemplate < ActiveRecord::Migration[5.2]
  def up
    add_column :gs_templates, :ws_template_id, :string
  end

  def down
    remove_column :gs_templates, :ws_template_id, :string
  end
end
