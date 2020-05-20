class AddFacebookDataToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :url, :string
    add_column :products, :connected_to_facebook, :boolean, default: false

    Product.where.not(facebook_product_id: nil).each do |product|
      product.update_column(:connected_to_facebook, true)
    end
  end

  def down
    remove_column :products, :url, :string
    remove_column :products, :connected_to_facebook, :boolean
  end
end
