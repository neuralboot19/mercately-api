ActiveAdmin.register Customer do
  permit_params :email, :first_name, :last_name

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :retailer
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
        row :phone
      end
    end
  end

  filter :email

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
    end
    f.actions
  end
end
