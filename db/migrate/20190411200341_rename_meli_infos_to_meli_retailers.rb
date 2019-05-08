class RenameMeliInfosToMeliRetailers < ActiveRecord::Migration[5.2]
  def change
    rename_table :meli_infos, :meli_retailers
  end
end
