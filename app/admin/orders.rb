ActiveAdmin.register Order do

  show do 
    default_main_content
    panel "Usuario de ML" do
      order_items = Order.find(params['id']).order_items
      table_for order_items do
        column :product
        column :quantity
        column :created_at
        column :unit_price
        column :updated_at
      end
    end
  end
end
