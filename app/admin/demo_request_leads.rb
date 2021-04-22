ActiveAdmin.register DemoRequestLead do
  permit_params :name,
                :email,
                :company,
                :employee_quantity,
                :country,
                :phone,
                :message,
                :problem_to_resolve,
                :status

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :company
    column :country
    column :phone
    column :status

    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :company
      f.input :employee_quantity
      f.input :country
      f.input :phone
      f.input :message
      f.input :problem_to_resolve
      f.input :status
    end

    f.actions
  end
end
