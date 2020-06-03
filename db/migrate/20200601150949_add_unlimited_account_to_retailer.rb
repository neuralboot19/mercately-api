class AddUnlimitedAccountToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :unlimited_account, :boolean, default: false
  end

  def down
    remove_column :retailers, :unlimited_account, :boolean
  end
end
