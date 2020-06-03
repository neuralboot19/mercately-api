ActiveAdmin.register GupshupWhatsappMessage do
  filter :retailer
  filter :retailer_user

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
