class AddKarixAccountTokenToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :karix_account_token, :string
  end

  def down
    remove_column :retailers, :karix_account_token, :string
  end
end
