ActiveAdmin.register Product do
  permit_params :title,
    :subtitle,
    :category_id,
    :price,
    :available_quantity,
    :buying_mode,
    :condition,
    :description,
    images: []
end
