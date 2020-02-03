ActiveAdmin.register KarixWhatsappTemplate do
  permit_params :text,
                :status,
                :retailer_id

  filter :text
  filter :status
  filter :retailer

  index do
    selectable_column
    id_column
    column :text
    column :status
    column :retailer
    column :created_at
    column :updated_at
  end
end
