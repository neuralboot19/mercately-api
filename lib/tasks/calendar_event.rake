namespace :calendar_event do
  task send_reminders: :environment do
    current_time = Time.now
    CalendarEvent.where(remember_at: current_time..current_time + 1.minute).find_each do |ce|
      CalendarEventMailer.remember(ce.id).deliver_now
    end
  end
end
