namespace :calendar_event do
  task send_reminders: :environment do
    ReminderJob.perform_later
  end
end
