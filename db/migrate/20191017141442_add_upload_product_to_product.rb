class AddUploadProductToProduct < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :upload_product, :boolean

    Product.where('meli_product_id IS NOT NULL').update_all(upload_product: true)
  end

  def down
    remove_column :products, :upload_product, :boolean
  end
end
