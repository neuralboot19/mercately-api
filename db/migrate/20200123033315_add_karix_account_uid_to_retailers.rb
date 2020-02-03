class AddKarixAccountUidToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :karix_account_uid, :string
  end
end
