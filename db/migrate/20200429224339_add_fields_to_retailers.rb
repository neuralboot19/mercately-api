class AddFieldsToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :gupshup_phone_number, :string
    add_column :retailers, :gupshup_src_name, :string

    add_index :retailers, [:gupshup_src_name], unique: true
  end
end
