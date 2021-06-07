namespace :gs_templates do
  task update_submmited_status: :environment do
    GsTemplate.where(status: :pending, submitted: true).update_all(status: :submitted)
  end
end
