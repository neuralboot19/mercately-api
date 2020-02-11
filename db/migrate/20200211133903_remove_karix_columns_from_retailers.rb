class RemoveKarixColumnsFromRetailers < ActiveRecord::Migration[5.2]
  def up
    remove_column :retailers, :karix_account_uid, :string
    remove_column :retailers, :karix_account_token, :string
  end

  def down
    add_column :retailers, :karix_account_uid, :string
    add_column :retailers, :karix_account_token, :string
  end
end
