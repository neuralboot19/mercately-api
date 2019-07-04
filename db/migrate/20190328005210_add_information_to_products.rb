class AddInformationToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :meli_product_id, :string
    add_column :products, :meli_site_id, :string
    add_column :products, :subtitle, :string
    add_column :products, :base_price, :decimal
    add_column :products, :original_price, :decimal
    add_column :products, :initial_quantity, :integer
    add_column :products, :sold_quantity, :integer
    add_column :products, :meli_start_time, :datetime
    add_column :products, :meli_listing_type_id, :string
    add_column :products, :meli_stop_time, :datetime
    add_column :products, :meli_end_time, :datetime
    add_column :products, :meli_expiration_time, :datetime
    add_column :products, :meli_permalink, :string
  end
end
