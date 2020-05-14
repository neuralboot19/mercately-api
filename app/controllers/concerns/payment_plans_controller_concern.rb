module PaymentPlansControllerConcern
  extend ActiveSupport::Concern

  MONTH_NAMES = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ]

  def used_whatsapp_messages
    whatsapp_messages = current_retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'
    messages = current_retailer.send(whatsapp_messages).range_between(@payment_plan.start_date, Time.now)

    @conversations = messages.group_by_month(:created_at).conversation_messages.count
    @notifications = messages.group_by_month(:created_at).notification_messages.count

    keys = (@conversations.keys + @notifications.keys).uniq.sort
    @user_messages = []

    keys.each do |p|
      data = {
        month: MONTH_NAMES[p.month],
        year: p.year.to_s,
        total_conversation: 0,
        total_notification: 0
      }

      if (@conversations.has_key?(p))
        data[:total_conversation] = @conversations[p]
      end

      if (@notifications.has_key?(p))
        data[:total_notification] = @notifications[p]
      end

      @user_messages << data
    end
  end
end
