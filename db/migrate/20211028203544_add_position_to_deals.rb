class AddPositionToDeals < ActiveRecord::Migration[5.2]
  def change
    add_column :deals, :position, :integer, default: 0, null: false
  end
end
