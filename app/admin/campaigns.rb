ActiveAdmin.register Campaign do
  actions :index, :show

  index do
    selectable_column
    id_column
    column :name
    column :status
    column :send_at
    column :retailer
    column :cost

    actions
  end

  filter :retailer, as: :searchable_select
end
