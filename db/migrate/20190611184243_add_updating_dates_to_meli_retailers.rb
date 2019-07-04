class AddUpdatingDatesToMeliRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :meli_retailers, :meli_token_updated_at, :datetime
    add_column :meli_retailers, :meli_info_updated_at, :datetime
  end
end
