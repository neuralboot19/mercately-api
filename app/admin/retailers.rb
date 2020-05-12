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
                :karix_whatsapp_phone,
                :ws_balance,
                :ws_notification_cost,
                :ws_conversation_cost,
                :gupshup_phone_number,
                :gupshup_src_name
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
    column 'Karix Phone Number' do |retailer|
      retailer.karix_whatsapp_phone
    end
    column :ws_balance
    column :retailer_user
    column :created_at
    actions
    column 'Login' do |resource|
      link_to 'Login as', login_as_admin_retailer_path(resource), class: 'member_link edit_link'
    end

    column 'Agregar Saldo' do |resource|
      link_to 'Agregar Saldo', new_admin_top_up_path(retailer_id: resource.id), class: 'member_link edit_link'
    end
  end

  csv do
    column :id
    column :name
    column(:email) { |retailer| retailer.retailer_user.email }
    column(:first_name) { |retailer| retailer.retailer_user.first_name }
    column(:last_name) { |retailer| retailer.retailer_user.last_name }
    column :city
    column :phone_number
    column :retailer_number
    column :ws_balance
    column :karix_whatsapp_phone
    column :ws_notification_cost
    column :ws_conversation_cost
    column :gupshup_phone_number
    column :created_at
  end

  show do
    attributes_table title: 'Detalles del Retailer' do
      row :id
      row :name
      row :first_name do |retailer|
        retailer.retailer_user&.first_name
      end
      row :last_name do |retailer|
        retailer.retailer_user&.last_name
      end
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
        row :karix_whatsapp_phone
        row :karix_account_uid
        row :karix_account_token
        row :gupshup_src_name
        row :gupshup_phone_number
        row 'Saldo' do |retailer|
          retailer.ws_balance
        end
        row 'Cantidad(Gupshup) de Mensajes de Entrada' do
          retailer.gupshup_whatsapp_messages.where(direction: 'inbound').count
        end
        row 'Cantidad(Gupshup) de Mensajes de Salida' do
          retailer.gupshup_whatsapp_messages.where(direction: 'outbound').count
        end
        row 'Total(Gupshup) de Mensajes Gestionados' do
          retailer.gupshup_whatsapp_messages.count
        end
        row 'Costo(Karix) por mensaje de Notificación' do
          retailer.ws_notification_cost
        end
        row 'Costo(Karix) por mensaje de Conversación' do
          retailer.ws_conversation_cost
        end
        row 'Cantidad(Karix) de Mensajes de Notificación' do
          retailer.notification_messages.count
        end
        row 'Cantidad(Karix) de Mensajes de Conversación' do
          retailer.conversation_messages.count
        end
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
      f.input :karix_whatsapp_phone
      f.input :karix_account_uid
      f.input :karix_account_token
      f.input :ws_balance
      f.input :ws_notification_cost
      f.input :ws_conversation_cost
      f.input :gupshup_phone_number
      f.input :gupshup_src_name
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
    session[:room_id] = retailer_user.id
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
