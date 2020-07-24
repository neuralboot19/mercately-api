class PaymentPlan < ApplicationRecord
  belongs_to :retailer

  enum status: %i[active inactive], _prefix: true
  enum plan: %i[free basic professional advanced enterprise]

  def notify_slack
    slack_client.ping([
      '🎉 Tiempo de cobrar 🎉',
      "Retailer: (#{retailer.id})#{retailer.name}",
      "Email para la factura: #{retailer.admins.pluck(:email).join(', ')}",
      "Teléfono de contacto: #{retailer.phone_number}",
      "Monto: #{price}",
      "Status del mes pasado: #{status}"
    ].join("\n"))
    # Updates the next notification date
    npd = (next_pay_date || Date.today) + 1.month
    update(
      next_pay_date: npd
    )

    # We must convert the next pay date to a timestamp to shedule the job
    # since self.next_pay_date is type Date instead of type Time
    next_notification_at = Time.parse(npd.to_s).to_i

    # Schedule the next alert
    Retailers::RetailerChargeAlertJob.perform_at(
      next_notification_at,
      id
    ) unless Rails.env == 'test'
  end

  def is_active?
    status == 'active'
  end

  private

    def slack_client
      Slack::Notifier.new ENV['SLACK_WEBHOOK']
    end
end
