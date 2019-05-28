class AddHasMeliInfoToMeliRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :meli_retailers, :has_meli_info, :boolean, default: false
  end
end
