ActiveAdmin.register PaymentezTransaction do
  menu parent: 'Transacciones'
  actions :all, except: %i[edit update destroy]

  controller do
    defaults finder: :find_by_web_id
  end

  index do
    selectable_column
    id_column
    column :status
    column :payment_date
    column :amount
    column :authorization_code
    column :message
    column :pt_id
    column :status_detail
    column :transaction_reference
    column :retailer_id
    column :payment_plan_id
    column :paymentez_credit_card_id
    column :created_at
    actions
  end
end
