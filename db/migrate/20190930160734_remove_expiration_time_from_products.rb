class RemoveExpirationTimeFromProducts < ActiveRecord::Migration[5.2]
  def up
    remove_column :products, :meli_expiration_time, :datetime
  end

  def down
    add_column :products, :meli_expiration_time, :datetime
  end
end
