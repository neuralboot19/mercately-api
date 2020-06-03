ActiveAdmin.register KarixWhatsappMessage do
  filter :retailer
  filter :retailer_user

  index do
    selectable_column
    column :id
    column 'Contenido' do |message|
      if message.content_type == 'text' || message.content_type == 'location'
        message.content_type
      else
        message.content_media_type
      end
    end
    column :retailer
    column 'Agente' do |message|
      message.retailer_user&.full_name.presence || message.retailer_user&.email
    end
    column :created_at
    column :updated_at
  end
end
