namespace :tags do
  task update_deleted: :environment do
    Tag.unscoped.in_batches do |batch|
      batch.update_all(deleted: false)
    end
  end
end
