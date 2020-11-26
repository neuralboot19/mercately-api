ActiveAdmin.register WhatsappTemplate do
  permit_params :text, :status, :retailer_id, :template_type

  filter :text
  filter :status
  filter :template_type
  filter :retailer, as: :searchable_select

  index do
    selectable_column
    id_column
    column :text
    column :status
    column :retailer
    column :template_type
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :retailer, as: :searchable_select
      f.input :text
      f.input :status
      f.input :template_type
    end

    f.actions do
      f.actions
    end
  end
end
