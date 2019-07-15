ActiveAdmin.register Product do
  permit_params :title,
                :subtitle,
                :category_id,
                :price,
                :available_quantity,
                :buying_mode,
                :condition,
                :description,
                :main_picture_id,
                :sold_quantity,
                ml_attributes: [],
                images: []

  index do
    selectable_column
    id_column
    column :title
    column :description
    column :retailer
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table title: 'Detalles del Producto' do
      row :id
      row :title
      row :price
      row :available_quantity
      row :description
      row :retailer_id
      row :created_at
      row :updated_at
      row :meli_product_id
      row :meli_site_id
      row :subtitle
      row :base_price
      row :original_price
      row :initial_quantity
      row :sold_quantity
      row :meli_start_time
      row :meli_listing_type_id
      row :meli_stop_time
      row :meli_end_time
      row :meli_expiration_time
      row :meli_permalink
      row :category_id
      row :buying_mode
      row :condition
      row :main_picture_id
      row :ml_attributes
    end

    panel 'Variaciones' do
      variations = ProductVariation.where(product_id: product.id)
      attributes_table_for variations do
        row :id
        row :variation_meli_id
        row :data
        row :created_at
        row :updated_at
      end
    end
  end
end
