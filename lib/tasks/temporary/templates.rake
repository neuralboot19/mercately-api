namespace :templates do
  task update_file_type: :environment do
    Template.find_each do |t|
      t.update_column(:file_type, :image) if t.image.attached?
    end
  end
end
