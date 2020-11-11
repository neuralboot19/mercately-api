ActiveAdmin.register_page 'Estadisticas' do
  menu parent: 'Estadisticas', label: 'Estadisticas'

  content title: 'Estadisticas' do
    table do
      thead do
        tr do
          %w[Campaña Total].each(&method(:th))
        end
      end
      tbody do
        Ahoy::Visit.pluck(:utm_campaign).uniq.each do |utm_campaign|
          tr do
            td do
              utm_campaign || 'Sin Campaña'
            end
            td do
              Ahoy::Visit.where(utm_campaign: utm_campaign).count
            end
          end
        end
      end
    end
    table do
      thead do
        tr do
          %w[Source Total].each(&method(:th))
        end
      end
      tbody do
        Ahoy::Visit.pluck(:utm_source).uniq.each do |utm_source|
          tr do
            td do
              utm_source || 'Sin Campaña'
            end
            td do
              Ahoy::Visit.where(utm_source: utm_source).count
            end
          end
        end
      end
    end
    table do
      thead do
        tr do
          %w[Landing Total].each(&method(:th))
        end
      end
      tbody do
        [root_url, new_retailer_user_registration_url, blog_url].each do |url|
          tr do
            td do
              url
            end
            td do
              Ahoy::Visit.where("landing_page LIKE '#{url}?%'").count
            end
          end
        end
      end
    end
  end
end
