ActiveAdmin.register_page 'Estadisticas de eventos' do
  menu parent: 'Estadisticas', label: 'Estadisticas de eventos'

  content title: 'Estadisticas de eventos' do
    render partial: 'statistics_events'
  end
end
