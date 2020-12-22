class CalendarEventMailer < ApplicationMailer
  def remember(id)
    @calendar_event = CalendarEvent.find(id)
    @retailer_user = @calendar_event.retailer_user

    mail to: @calendar_event.retailer_user.email,
      subject: 'Recordatorio de Evento'
  end
end
