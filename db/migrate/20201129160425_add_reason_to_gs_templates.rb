class AddReasonToGsTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :gs_templates, :reason, :text
  end
end
