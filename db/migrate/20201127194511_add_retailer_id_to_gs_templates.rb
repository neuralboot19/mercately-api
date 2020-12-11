class AddRetailerIdToGsTemplates < ActiveRecord::Migration[5.2]
  def change
    add_reference :gs_templates, :retailer, foreign_key: true
  end
end
