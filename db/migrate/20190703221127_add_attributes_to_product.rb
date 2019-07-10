class AddAttributesToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :ml_attributes, :jsonb, default: []
  end
end
