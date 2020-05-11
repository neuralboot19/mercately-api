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

  def used_karix_whatsapp_messages
    messages = current_retailer.karix_whatsapp_messages.range_between(@payment_plan.start_date, Time.now)
    @conversations = messages.where(message_type: 'conversation').where.not(status: 'failed')
      .group_by_month(:created_at).count
    @notifications = messages.where(message_type: 'notification').where.not(status: 'failed')
      .group_by_month(:created_at).count

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
