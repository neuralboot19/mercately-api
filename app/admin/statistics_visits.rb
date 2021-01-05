ActiveAdmin.register_page 'Estadisticas de visitas' do
  menu parent: 'Estadisticas', label: 'Estadisticas de visitas'

  content title: 'Estadisticas de visitas' do
    render partial: 'statistics_visits'
  end
end
