class AddFieldsToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :id_type, :integer
    add_column :customers, :id_number, :string
    add_column :customers, :address, :string
    add_column :customers, :city, :string
    add_column :customers, :state, :string
    add_column :customers, :zip_code, :string
    add_column :customers, :country_id, :string
  end

  def down
    remove_column :customers, :id_type, :integer
    remove_column :customers, :id_number, :string
    remove_column :customers, :address, :string
    remove_column :customers, :city, :string
    remove_column :customers, :state, :string
    remove_column :customers, :zip_code, :string
    remove_column :customers, :country_id, :string
  end
end
