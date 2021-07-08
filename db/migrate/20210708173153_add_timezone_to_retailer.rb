class AddTimezoneToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :timezone, :string
  end

  def down
    remove_column :retailers, :timezone, :string
  end
end
