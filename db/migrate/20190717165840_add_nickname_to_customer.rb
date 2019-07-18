class AddNicknameToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :meli_nickname, :string
  end

  def down
    remove_column :customers, :meli_nickname, :string
  end
end
