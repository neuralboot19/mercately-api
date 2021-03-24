class AddArchivedToContactGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_groups, :archived, :boolean, default: false
  end
end
