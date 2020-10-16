require 'rake'
module Categories
  class UpdateJob
    include Sidekiq::Worker

    def perform
      Rails.application.load_tasks
      Rake::Task['update_categories'].invoke
    end
  end
end
