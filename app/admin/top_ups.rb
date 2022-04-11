ActiveAdmin.register TopUp do
  actions :all, except: :destroy
  permit_params :retailer_id,
                :amount

  filter :retailer_slug_cont, label: 'Retailer\'s Slug'
  filter :retailer_name_cont, label: 'Retailer\'s Name'

  index do
    id_column
    column :retailer do |tu|
      "#{tu.retailer.name}(#{tu.retailer.slug})"
    end
    column :amount
    column :created_at
    actions
  end

  show do
    attributes_table title: 'Detalles del Retailer' do
      row :id
      row :retailer
      row :amount
      row :created_at

      row 'Retailer' do |tu|
        tu.retailer.name
      end

      row 'Saldo actual' do |tu|
        tu.retailer.ws_balance
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :retailer, as: :searchable_select, selected: params[:retailer_id]
      f.input :amount
    end

    f.actions do
      f.actions
    end
  end
end
