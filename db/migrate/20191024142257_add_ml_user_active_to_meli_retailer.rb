class AddMlUserActiveToMeliRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :meli_retailers, :meli_user_active, :boolean, default: true
  end

  def down
    remove_column :meli_retailers, :meli_user_active, :boolean
  end
end
