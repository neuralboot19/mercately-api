ActiveAdmin.register Order do
  actions :all, except: :destroy
  controller do
    defaults finder: :find_by_web_id
  end

  show do
    default_main_content
    panel 'Items' do
      order_items = order.order_items
      table_for order_items do
        column :product
        column :quantity
        column :created_at
        column :unit_price
        column :updated_at
      end
    end

    panel 'Chats' do
      questions = order.messages.order(:created_at)
      table_for questions do
        column :id
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
end
