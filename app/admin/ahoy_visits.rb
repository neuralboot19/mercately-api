ActiveAdmin.register Ahoy::Visit do
  menu parent: 'Estadisticas'
  actions :index

  filter :browser
  filter :os
  filter :device_type
  filter :landing_page
  filter :utm_source
  filter :utm_medium
  filter :utm_term
  filter :utm_content
  filter :utm_campaign
  filter :started_at

  index do
    selectable_column
    id_column
    column :browser
    column :os
    column :device_type
    column :landing_page
    column :utm_source
    column :utm_medium
    column :utm_term
    column :utm_content
    column :utm_campaign
    column :started_at
    actions
  end
end
