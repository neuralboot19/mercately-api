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
                :karix_account_uid,
                :karix_account_token,
                :ws_balance,
                :ws_notification_cost,
                :ws_conversation_cost,
                :gupshup_phone_number,
                :gupshup_src_name,
                :unlimited_account,
                :ecu_charges,
                :int_charges,
                :allow_bots,
                :gupshup_api_key,
                :manage_team_assignment,
                :show_stats,
                :allow_voice_notes,
                :allow_send_videos,
                :allow_multiple_answers,
                :max_agents,
                :ml_domain,
                :ml_site,
                :gupshup_app_id,
                :gupshup_app_token,
                :send_max_size_files
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
    column 'Karix Phone Number', &:karix_whatsapp_phone
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

    column 'Pago fallído' do |resource|
      link_to 'Enviar email', failed_charge_email_admin_retailer_path(resource.id), class:
        'member_link edit_link'
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
      row :unlimited_account
      row :ecu_charges
      row :int_charges
      row :allow_bots
      row :manage_team_assignment
      row :show_stats
      row :allow_voice_notes
      row :allow_send_videos
      row :allow_multiple_answers
      row :max_agents
      row :ml_domain
      row :ml_site
      row :send_max_size_files
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
        row :gupshup_api_key
        row :gupshup_app_id
        row :gupshup_app_token
        row 'Saldo', &:ws_balance
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
      attributes_table_for retailer do
        row 'Hace pagos en Ecuador' do
          retailer.ecu_charges
        end
        row 'Hace pagos internacionales' do
          retailer.int_charges
        end
      end
      plan = retailer.payment_plan
      attributes_table_for plan do
        row :price
        row :month_interval
        row :start_date
        row :next_pay_date
        row :status
        row :plan
      end
    end

    panel 'Métodos de Pago' do
      if retailer.ecu_charges
        table_for retailer.paymentez_credit_cards do
          column 'card_type' do |pcc|
            PaymentezCardHelper.brand(pcc.card_type)
          end
          column :name
          column :number
          column :token
          column 'Expiration Date' do |pcc|
            "#{pcc['expiry_month']}/#{pcc['expiry_year']}"
          end
          column :main
        end
      elsif retailer.int_charges
        table_for retailer.payment_methods do
          column 'payment_type', &:payment_type
          column 'number' do |pm|
            card = JSON.parse(pm.payment_payload)['card']
            card['last4']
          end
          column 'token', &:stripe_pm_id
          column 'Expiration Date' do |pm|
            card = JSON.parse(pm.payment_payload)['card']
            "#{card['exp_month']}/#{card['exp_year']}"
          end
          column 'Card\'s holder name' do |pm|
            billing_details = JSON.parse(pm.payment_payload)['billing_details']
            billing_details['name']
          end
        end
      end
    end

    panel 'Transacciones' do
      if retailer.ecu_charges
        table_for retailer.paymentez_transactions.order(id: :desc) do
          column :status
          column :payment_date
          column :amount
          column :authorization_code
          column :installments
          column :dev_reference
          column :message
          column :carrier_code
          column 'REF #', &:pt_id
          column :status_detail
          column :transaction_reference
          column 'Payment Plan' do |pt|
            pt.retailer.payment_plan.plan
          end
          column :paymentez_credit_card_id
          column 'Credit Card' do |pt|
            card = PaymentezCreditCard.unscoped.find(pt.paymentez_credit_card_id)
            type = PaymentezCardHelper.brand(card.card_type)

            "ID: #{card.id}, #{type},
             #####{card.number},
             #{card.expiry_month}/#{card.expiry_year}"
          end
          column 'Refund Transaction' do |pt|
            if pt.status == 'refund'
              ''
            else
              link_to 'Refund Transaction',
                      refund_paymentez_transaction_admin_retailer_path(pt.retailer, pt_id: pt),
                      class: 'member_link edit_link'
            end
          end
        end
      end
    end

    panel 'Agentes del retailer' do
      table_for retailer.retailer_users do
        column :id

        column 'Nombres', &:full_name

        column :email

        column 'Estado' do |ret_u|
          if ret_u.removed_from_team
            'Inactivo'
          elsif ret_u.invitation_token.blank?
            'Activo'
          else
            'Invitado'
          end
        end

        column 'Role' do |ret_u|
          if ret_u.retailer_admin == true
            'Administrador'
          elsif ret_u.retailer_supervisor == true
            'Supervisor'
          else
            'Agente'
          end
        end

        column 'Iniciar sesión' do |ret_u|
          link_to 'Login as', login_as_admin_retailer_path(ret_u.retailer, retailer_user_email: ret_u.email), class:
            'member_link edit_link'
        end
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
      f.input :unlimited_account
      f.input :whats_app_enabled
      f.input :ml_site, as: :select, collection: [%w[Ecuador MEC], %w[Chile MLC], ['Costa Rica', 'MCR']]
      f.input :ml_domain
      f.input :karix_whatsapp_phone
      f.input :karix_account_uid
      f.input :karix_account_token
      f.input :ws_balance
      f.input :ws_notification_cost
      f.input :ws_conversation_cost
      f.input :gupshup_phone_number
      f.input :gupshup_src_name
      f.input :gupshup_api_key
      f.input :max_agents
      f.input :gupshup_app_id
      f.input :gupshup_app_token
      f.input :ecu_charges, label: 'Hace pagos en Ecuador'
      f.input :int_charges, label: 'Hace pagos Internacionales'
      f.input :allow_bots, label: 'Tiene permitido administrar ChatBots'
      f.input :manage_team_assignment, label: 'Activar Asignación Automática'
      f.input :show_stats, label: 'Activar acceso total a estadísticas'
      f.input :allow_voice_notes, label: 'Permitir envío de notas de voz'
      f.input :allow_send_videos, label: 'Permitir enviar videos'
      f.input :allow_multiple_answers, label: 'Permitir enviar varias respuestas en el ChatBot'
      f.input :send_max_size_files, label: 'Enviar hasta 40MB en pdfs y 15MB en imagenes'
    end
    f.actions
  end

  controller do
    defaults finder: :find_by_slug
  end

  # Custom actions
  member_action :login_as do
    retailer = Retailer.find_by(slug: params[:id])
    retailer_user = params[:retailer_user_email].present? ? retailer.retailer_users
      .find_by_email(params[:retailer_user_email]) : retailer.retailer_users.first
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

  member_action :refund_paymentez_transaction do
    pt = PaymentezTransaction.find(params[:pt_id]).refund
    flash[:alert] = pt[:message]
    redirect_to admin_retailers_path
  end

  member_action :failed_charge_email do
    retailer = Retailer.find(params[:id])

    retailer.send_failed_charge_email
    flash[:alert] = 'Email enviado con éxito'
    redirect_to admin_retailers_path
  end
end
