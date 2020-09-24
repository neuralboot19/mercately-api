class AddRetailerUserToTemplate < ActiveRecord::Migration[5.2]
  def up
    add_reference :templates, :retailer_user
    add_column :templates, :global, :boolean, default: false
  end

  def down
    remove_reference :templates, :retailer_user
    remove_column :templates, :global, :boolean
  end
end
