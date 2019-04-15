class MakeEnumsInProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :buying_mode, :string
    add_column :products, :buying_mode, :integer
  end
end
