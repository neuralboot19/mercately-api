ActiveAdmin.register GupshupWhatsappMessage do
  actions :all, except: :destroy
  filter :retailer, as: :searchable_select
  filter :retailer_user, as: :searchable_select

  index do
    selectable_column
    column :id
    column 'Contenido' do |message|
      message.message_payload['type']
    end
    column :retailer
    column 'Agente' do |message|
      message.retailer_user&.full_name.presence || message.retailer_user&.email
    end
    column :created_at
    column :updated_at
  end
end
