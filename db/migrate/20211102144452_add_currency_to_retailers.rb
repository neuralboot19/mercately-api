class AddCurrencyToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :currency, :string, default: 'USD', null: false
  end

  def down
    remove_column :retailers, :currency, :string
  end
end
