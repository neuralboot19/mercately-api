ActiveAdmin.register Product do
  actions :all, except: :destroy
  preserve_default_filters!
  remove_filter :category, :order_items, :questions, :images_blobs, :images_attachments, :product_variations

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
                :status,
                :meli_status,
                :code,
                :brand,
                :url,
                ml_attributes: [],
                images: []

  controller do
    defaults finder: :find_by_web_id
  end

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
      row :meli_permalink
      row :category_id
      row :buying_mode
      row :condition
      row :status
      row :meli_status
      row :code
      row :brand
      row :url
      row :main_picture_id
      row :ml_attributes
    end

    panel 'Variaciones' do
      variations = ProductVariation.where(product_id: product.id)
      attributes_table_for variations do
        row :id
        row :variation_meli_id
        row :status
        row :data
        row :created_at
        row :updated_at
      end
    end
  end
end
