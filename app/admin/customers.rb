ActiveAdmin.register Customer do
  permit_params :first_name,
                :last_name,
                :email,
                :id_type,
                :id_number,
                :address,
                :city,
                :state,
                :zip_code,
                :country_id

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    actions
  end

  show do
    default_main_content
    panel 'Usuario de ML' do
      customer = Customer.find(params['id']).meli_customer
      attributes_table_for customer do
        row :access_token
        row :meli_user_id
        row :nickname
        row :email
        row :points
        row :link
        row :seller_experience
        row :seller_reputation_level_id
        row :transactions_canceled
        row :transactions_completed
        row :ratings_negative
        row :ratings_neutral
        row :ratings_positive
        row :ratings_total
        row :customer_id
        row :phone_area
        row :phone
        row :phone_verified
        row :buyer_canceled_transactions
        row :buyer_completed_transactions
        row :buyer_canceled_paid_transactions
        row :buyer_unrated_paid_transactions
        row :buyer_unrated_total_transactions
        row :buyer_not_yet_rated_paid_transactions
        row :buyer_not_yet_rated_total_transactions
        row :meli_registration_date
      end
    end
  end

  filter :email

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :id_type
      f.input :id_number
      f.input :address
      f.input :city
      f.input :state
      f.input :zip_code
      f.input :country_id
    end
    f.actions
  end
end
