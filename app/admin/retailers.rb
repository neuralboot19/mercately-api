ActiveAdmin.register Retailer do
  permit_params :name,
                :id_type,
                :id_number,
                :address,
                :city,
                :state,
                :zip_code,
                :phone_number,
                :whats_app_enabled,
                :karix_account_uid,
                :karix_account_token,
                :karix_whatsapp_phone
  
  filter :name
  filter :slug
  filter :meli_retailer_meli_user_id_cont, label: 'Meli user id'
  filter :retailer_user_email_cont, label: 'Retailer user email'
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column 'Meli User Id' do |retailer|
      retailer.meli_retailer&.meli_user_id
    end
    column 'Facebook User Id' do |retailer|
      retailer.facebook_retailer&.uid
    end
    column 'WhatsApp Account Id' do |retailer|
      retailer.karix_account_uid
    end
    column :retailer_user
    column :created_at
    actions
    column 'Login' do |resource|
      link_to 'Login as', login_as_admin_retailer_path(resource), class: 'member_link edit_link'
    end
  end

  csv do
    column :id
    column :name
    column(:email) { |retailer| retailer.retailer_user.email }
    column :city
    column :phone_number
    column :retailer_number
    column :created_at
  end

  show do
    attributes_table title: 'Detalles del Retailer' do
      row :id
      row :name
      row :retailer_number
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

    panel 'Información de Facebook' do
      fb_info = retailer.facebook_retailer
      attributes_table_for fb_info do
        row :id
        row :uid
        row :access_token
        row :created_at
        row :updated_at
      end
    end

    panel 'Información de WhatsApp' do
      attributes_table_for retailer do
        row :whats_app_enabled
        row :karix_account_uid
        row :karix_account_token
        row :karix_whatsapp_phone
      end
    end

    panel 'Plan' do
      plan = retailer.payment_plan
      attributes_table_for plan do
        row :price
        row :start_date
        row :next_pay_date
        row :status
        row :plan
        row :karix_available_messages
        row :karix_available_notifications
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
      f.input :whats_app_enabled
      f.input :karix_account_uid
      f.input :karix_account_token
      f.input :karix_whatsapp_phone
    end
    f.actions
  end

  controller do
    defaults finder: :find_by_slug
  end

  # Custom actions
  member_action :login_as do
    retailer = Retailer.find_by(slug: params[:id])
    retailer_user = retailer.retailer_users.first
    session[:old_retailer_id] = current_retailer_user.retailer.slug if current_retailer_user
    session[:current_retailer] = retailer
    sign_in(:retailer_user, retailer_user)
    redirect_to root_path
  end

  member_action :go_back_as_admin do
    if session[:old_retailer_id]
      retailer = Retailer.find_by(slug: session[:old_retailer_id])
      retailer_user = retailer.retailer_users.first
      session[:current_retailer] = retailer
      session.delete(:old_retailer_id)
      sign_in(:retailer_user, retailer_user)
    end
    redirect_to admin_retailers_path
  end
end
