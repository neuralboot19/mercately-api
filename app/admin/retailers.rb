ActiveAdmin.register Retailer do
  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :created_at
    actions
    column 'Login' do |resource|
      link_to 'Login as', login_as_admin_retailer_path(resource), class: 'member_link edit_link'
    end
  end

  filter :name
  filter :slug
  filter :created_at

  show do
    attributes_table title: 'Detalles del Retailer' do
      row :id
      row :name
      row :slug
      row :id_type
      row :id_number
      row :address
      row :city
      row :state
      row :zip_code
      row :phone_number
      row :phone_verified
      row :created_at
      row :updated_at
    end

    panel 'Información de Mercado Libre' do
      meli_information = MeliRetailer.find_by(retailer_id: retailer.id)
      attributes_table_for meli_information do
        row :id
        row :nickname
        row :email
        row :access_token
        row :meli_user_id
        row :refresh_token
        row :points
        row :link
        row :seller_experience
        row :seller_reputation_level_id
        row :transactions_canceled
        row :transactions_completed
        row :ratings_negative
        row :ratings_positive
        row :ratings_neutral
        row :ratings_total
        row :phone
        row :has_meli_info
        row :retailer_id
        row :customer_id
        row :meli_token_updated_at
        row :meli_info_updated_at
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :id_type
      f.input :id_number
      f.input :address
      f.input :city
      f.input :state
      f.input :zip_code
      f.input :phone_number
    end
    f.actions
  end

  controller do
    defaults finder: :find_by_slug
  end

  # Custom actions
  member_action :login_as do
    retailer_user = Retailer.find_by(slug: params[:id]).retailer_users.first
    session[:old_retailer_id] = current_retailer_user.id if current_retailer_user
    session[:current_retailer] = retailer_user
    sign_in(:retailer_user, retailer_user)
    redirect_to root_path
  end

  member_action :go_back_as_admin do
    if session[:old_retailer_id].present?
      retailer_user = RetailerUser.find(session[:old_retailer_id])
      sign_in(:retailer_user, retailer_user)
      session.delete(:old_retailer_id)
    end
    redirect_to admin_root_path
  end
end
