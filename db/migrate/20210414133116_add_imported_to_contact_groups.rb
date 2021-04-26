class AddImportedToContactGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_groups, :imported, :boolean, default: false
  end
end
