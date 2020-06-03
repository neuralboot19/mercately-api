ActiveAdmin.register FacebookMessage do
  filter :facebook_retailer_retailer_name, as: :string, label: 'RETAILER NAME'
  filter :retailer_user

  index do
    selectable_column
    column :id
    column 'Contenido' do |message|
      if message.text.present?
        'texto'
      else
        message.file_type
      end
    end
    column 'Retailer' do |message|
      message.facebook_retailer.retailer
    end
    column 'Agente' do |message|
      message.retailer_user&.full_name.presence || message.retailer_user&.email
    end
    column :created_at
    column :updated_at
  end
end
