ActiveAdmin.register Reminder do
  actions :all, except: [:new, :create, :destroy]
  permit_params :status
  filter :retailer, as: :searchable_select
  filter :retailer_user, as: :searchable_select
  filter :customer, as: :searchable_select, collection: Customer.where(valid_customer: true)
    .map { |c| [c.full_names.presence || c.whatsapp_name || c.phone, c.id] }

  controller do
    defaults finder: :find_by_web_id
  end

  index do
    selectable_column
    id_column
    column :retailer
    column 'Agente' do |r|
      r.retailer_user.full_name.presence || r.retailer_user.email
    end
    column 'Cliente' do |r|
      link_to (r.customer.full_names.presence || r.customer.phone), admin_customer_path(r.customer)
    end
    column 'Contenido' do |r|
      r.whatsapp_template.text
    end
    column :status
    column :send_at
    column :created_at
    column :updated_at
  end

  show do
    attributes_table title: 'Detalles del Recordatorio' do
      row :id
      row :retailer
      row 'Agente' do |r|
        r.retailer_user.full_name.presence || r.retailer_user.email
      end
      row 'Cliente' do |r|
        link_to (r.customer.full_names.presence || r.customer.phone), admin_customer_path(r.customer)
      end
      row 'Contenido' do |r|
        r.whatsapp_template.text
      end
      row :status
      row :send_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :retailer, input_html: { disabled: true }
      f.input :retailer_user, input_html: { disabled: true }
      f.input :customer, collection: Customer.where(valid_customer: true)
        .map { |c| [c.full_names.presence || c.whatsapp_name || c.phone, c.id] }, input_html:
        { disabled: true, selected: f.object }
      f.input :status
      f.input :send_at, input_html: { disabled: true }
    end
    f.actions
  end
end
