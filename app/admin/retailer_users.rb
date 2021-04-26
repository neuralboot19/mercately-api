ActiveAdmin.register RetailerUser do
  permit_params :first_name,
                :last_name,
                :email,
                :removed_from_team,
                :retailer_admin,
                :retailer_supervisor,
                :retailer_id

  filter :retailer, as: :searchable_select
  filter :first_name
  filter :last_name
  filter :email

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :retailer
    column :removed_from_team
    column :retailer_admin
    column :retailer_supervisor

    actions
  end

  form do |f|
    f.inputs do
      f.input :retailer, as: :searchable_select
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :retailer_admin
      f.input :retailer_supervisor
      f.input :removed_from_team
    end

    f.actions do
      f.actions
    end
  end

  csv do
    column :id
    column :first_name
    column :last_name
    column :email
    column (:retailer) { |retailer_user| retailer_user.retailer.name }
    column :removed_from_team
    column :retailer_admin
    column :retailer_supervisor
    column :created_at
    column :updated_at
  end
end
