namespace :retailers do
  task update_gs_templates: :environment do
    Retailers::GsTemplatesJob.perform_later
  end
end