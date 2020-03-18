class AddPackInfoToOrders < ActiveRecord::Migration[5.2]
  def up
    return true if Rails.env == 'test'
    unless Order.column_names.include?('pack_id')
      add_column :orders, :pack_id, :string
    end
  end

  def down
    return true if Rails.env == 'test'
    remove_column :orders, :pack_id, :string
  end
end
