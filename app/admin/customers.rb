ActiveAdmin.register Customer do
  permit_params :email, :first_name, :last_name

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
    panel "Usuario de ML" do
      customer = Customer.find(params['id']).meli_customer
      table_for customer do
        column :access_token
        column :meli_user_id
        column :nickname
        column :email
        column :points
        column :link
        column :seller_experience
        column :seller_reputation_level_id
        column :transactions_canceled
        column :transactions_completed
        column :ratings_negative
        column :ratings_neutral
        column :ratings_positive
        column :ratings_total
        column :customer_id
        column :phone
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
