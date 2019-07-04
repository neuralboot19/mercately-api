class AddDetailsToRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :id_number, :string
    add_column :retailers, :id_type, :integer
    add_column :retailers, :address, :string
    add_column :retailers, :city, :string
    add_column :retailers, :state, :string
    add_column :retailers, :zip_code, :string
    add_column :retailers, :phone_number, :string
    add_column :retailers, :phone_verified, :boolean
  end
end
