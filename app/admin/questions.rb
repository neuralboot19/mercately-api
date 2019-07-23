ActiveAdmin.register Question do
  index do
    selectable_column
    id_column
    column :question
    column :customer do |cust|
      link_to cust.customer.meli_nickname, admin_customer_path(cust.customer)
    end
    column :answer
    column :product
    column :status
    actions
  end

  show do
    attributes_table title: 'Pregunta' do
      row :id
      row :question
      row :customer do |cust|
        link_to cust.customer.meli_nickname, admin_customer_path(cust.customer)
      end
      row :answer
      row :product
      row :meli_id
      row :deleted_from_listing
      row :hold
      row :status
      row :date_read
      row :site_id
      row :sender_id
      row :answer_status
      row :date_created_question
      row :date_created_answer
      row :meli_question_type
      row :created_at
      row :updated_at
    end
  end
end
