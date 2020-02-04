ActiveAdmin.register Customer do
  permit_params :email,
                :id_type,
                :id_number,
                :address,
                :city,
                :state,
                :zip_code,
                :country_id,
                :first_name,
                :last_name

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :meli_nickname
    column :retailer
    actions
  end

  controller do
    defaults finder: :find_by_web_id
  end

  show do
    default_main_content
    panel 'Usuario de ML' do
      customer = Customer.find_by(web_id: params['id']).meli_customer
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

    panel 'Orders' do
      orders = customer.orders
      table_for orders do
        column :id
        column :merc_status
        column :created_at
        column :meli_order_id
        column :total_amount
        column :status
        column :feedback_reason
        column :feedback_message
        column :feedback_rating
      end
    end

    panel 'Preguntas' do
      questions = customer.questions.where(meli_question_type: :from_product)
      table_for questions do
        column :id
        column :product
        column :question
        column :answer
        column :answer_status
        column :meli_id
        column :status
        column :date_created_question
        column :date_created_answer
      end
    end

    panel 'Chats' do
      questions = customer.messages.where(meli_question_type: Question.meli_question_types[:from_order])
        .order(:created_at)
      table_for questions do
        column :id
        column :order
        column :question
        column :answer
        column :meli_id
        column :date_read
        column :sender
        column :created_at
        column :updated_at
      end
    end
  end

  filter :email

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
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
