ActiveAdmin.register Category do
  scope :active
  scope :inactive

  index do
    selectable_column
    id_column
    column :name
    column 'Productos' do |cat|
      cat.products.size
    end
    column :meli_id
    column :status
    actions
  end

  filter :name
  filter :status

  show do
    attributes_table title: 'Detalles de la Categoría' do
      row :id
      row :name
      row :meli_id
      row :status
      row :ancestry
      row('Productos') { category.products.size }
      row :template
      row :created_at
      row :updated_at
    end

    panel 'Productos' do
      products = Product.where(category_id: category.id)
      table_for products do
        column :id
        column(:title) { |pro| link_to pro.title, admin_product_path(pro.id) }
        column :meli_product_id
        column :status
        column :available_quantity
        column :sold_quantity
        column :price
        column :created_at
        column :updated_at
      end
    end
  end
end
