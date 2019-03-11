ActiveAdmin.register Customer do
  permit_params :email, :first_name, :last_name

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    actions
  end

  filter :email

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
    end
    f.actions
  end
end
