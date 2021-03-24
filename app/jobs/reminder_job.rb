class ReminderJob < ApplicationJob
  queue_as :low

  def perform
    current_time = Time.now

    CalendarEvent.where(remember_at: current_time..current_time + 1.minute).reverse_each do |ce|
      CalendarEventMailer.remember(ce.id).deliver_later(queue: 'mailers')
    end

    Campaign.pending.where(send_at: [
      2.days.from_now..2.days.from_now + 1.minute,
      1.days.from_now..1.days.from_now + 1.minute,
      12.hours.from_now..12.hours.from_now + 1.minute,
      6.hours.from_now..6.hours.from_now + 1.minute,
      3.hours.from_now..3.hours.from_now + 1.minute,
      1.hours.from_now..1.hours.from_now + 1.minute
    ]).find_each do |c|
      next if c.retailer.ws_balance > c.estimated_cost

      RetailerUser.active_admins(c.retailer.id).each do |ru|
        CampaignMailer.reminder(c, ru).deliver_now
      end
    end

    Reminders::WhatsappTemplates.new.execute
    Campaigns::WhatsappTemplates.new.execute
  end
end
