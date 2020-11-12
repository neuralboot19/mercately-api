ActiveAdmin.register Ahoy::Event do
  menu parent: 'Estadisticas'
  actions :index
  filter :name

  index do
    selectable_column
    id_column
    column :name
    column :properties
    actions
  end
end
