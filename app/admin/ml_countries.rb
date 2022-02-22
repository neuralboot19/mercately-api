ActiveAdmin.register MlCountry do
  permit_params :name,
                :site,
                :domain

  filter :name

  index do
    selectable_column
    id_column
    column :name
    column :site
    column :domain

    actions
  end

  show do
    attributes_table do
      row :name
      row :site
      row :domain
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :site
      f.input :domain
    end

    f.actions
  end
end
