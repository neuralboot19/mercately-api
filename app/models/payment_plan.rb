class PaymentPlan < ApplicationRecord
  belongs_to :retailer

  enum status: %i[active inactive], _prefix: true
  enum plan: %i[free basic professional advanced enterprise]

  MAX_ATTEMPTS = 4

  def charge!(force_retry: false)
    if retailer.int_charges
      pm = retailer.payment_methods.main
      attempt = retailer.stripe_transactions.new(
        amount: price.to_i,
        payment_method: pm,
        create_charge: true
      )
      unless attempt.save
        payment_failed(force_retry)
        return false
      end
    else
      attempt = retailer.paymentez_credit_cards.main.create_transaction(true)
      unless attempt
        payment_failed(force_retry)
        return false
      end
    end

    # Updates the next notification date
    npd = if next_pay_date.day == 15.days.ago.day
            month_interval.months.from_now
          else
            month_interval.months.from_now.change(day: next_pay_date&.day || Date.today.day)
          end
    update(next_pay_date: npd, charge_attempt: 0)
    true
  end

  def notify_slack
    npd = (next_pay_date || Date.today) + month_interval.month
    ws_msg = if retailer.gupshup_integrated?
               retailer.gupshup_whatsapp_messages.where(created_at: month_interval.months.ago..Time.now).where.not(note: true)
             elsif retailer.karix_integrated?
               retailer.karix_whatsapp_messages.where(created_time: month_interval.months.ago..Time.now)
             end

    msg = [
      '🎉 Tiempo de cobrar 🎉',
      "Retailer: (#{retailer.id})#{retailer.name}",
      "Email para la factura: #{retailer.admins.pluck(:email).join(', ')}",
      "Teléfono de contacto: #{retailer.phone_number}",
      "Monto: #{price}",
      "Plan: #{plan}",
      "Meses del plan: #{month_interval}",
      "Status del mes pasado: #{status}",
      "Fecha de próximo cobro: #{npd}",
      "Cantidas de asesores: Admins (#{retailer.admins.count}), Supervisores (#{retailer.supervisors.count}), " \
        "Asesores (#{retailer.retailer_users.active_agents.count})"
    ]
    if ws_msg.exists?
      sent = ws_msg.outbound_messages.count
      msg.concat([
        "Whatsapp:",
        "Cantidad total de mensajes: #{ws_msg.count}",
        "Cantidad total de enviados: #{sent}",
        "Cantidad total de recibidos: #{ws_msg.inbound_messages.count}",
        "Cantidad de plantillas enviadas: #{ws_msg.notification_messages.count}",
        "Promedio de mensajes por asesor: #{sent / retailer.team_agents.count}",
        "Numero de chatbots atendidos: #{retailer.chat_bot_customers.includes(:chat_bot).where(chat_bots: { platform: :whatsapp }).count}"
      ])
    end
    if retailer.facebook_retailer
      fbms = retailer.facebook_retailer.facebook_messages.where(created_at: month_interval.months.ago..Time.now)
      sent_msn = fbms.where(sent_by_retailer: true).count
      msg.concat([
        "Messenger:",
        "Cantidad total de mensajes: #{fbms.count}",
        "Cantidad total de enviados: #{sent_msn}",
        "Cantidad total de recibidos: #{fbms.where(sent_by_retailer: false).count}",
        "Cantidad total de media files enviados (imagenes, archivos, etc): #{fbms.where.not(filename: [nil, '']).count}",
        "Promedio de mensajes por asesor: #{sent_msn / retailer.team_agents.count}",
        "Numero de chatbots atendidos: #{retailer.chat_bot_customers.includes(:chat_bot).where(chat_bots: { platform: :messenger }).count}"
      ])
    end

    slack_client.ping(msg.join("\n"))
  end

  def is_active?
    status == 'active'
  end

  private

    def slack_client
      Slack::Notifier.new ENV['SLACK_WEBHOOK']
    end

    def payment_failed(force_retry = false)
      increment!(:charge_attempt)
      status_inactive! if charge_attempt > MAX_ATTEMPTS && force_retry == false
    end
end
