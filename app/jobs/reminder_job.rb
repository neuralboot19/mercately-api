class ReminderJob < ApplicationJob
  queue_as :low

  def perform
    current_time = Time.now

    CalendarEvent.where(remember_at: current_time..current_time + 1.minute).reverse_each do |ce|
      CalendarEventMailer.remember(ce.id).deliver_later(queue: 'mailers')
    end

    Reminders::WhatsappTemplates.new.execute
  end
end
