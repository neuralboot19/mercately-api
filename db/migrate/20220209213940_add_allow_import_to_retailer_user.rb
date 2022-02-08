class AddAllowImportToRetailerUser < ActiveRecord::Migration[5.2]
  def up
    add_column :retailer_users, :allow_import, :boolean, default: false
  end

  def down
    remove_column :retailer_users, :allow_import, :boolean
  end
end
