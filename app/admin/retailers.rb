ActiveAdmin.register Retailer do
  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :created_at
    actions
  end

  filter :name
  filter :created_at
end
