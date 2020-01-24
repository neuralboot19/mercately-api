class PaymentPlan < ApplicationRecord
  belongs_to :retailer

  enum status: %i[active inactive], _prefix: true
  enum plan: %i[free basic professional advanced enterprise]

  def notify_slack
    SlackNotifier::CLIENT.ping([
      '🎉 Tiempo de cobrar 🎉',
      "Retailer: #{retailer.name},",
      "Email para la factura: #{email}",
      "Monto: #{price}",
      "Status del mes pasado: #{status}"
    ].join("\n"))
    update(
      status: :unpaid,
      next_payday: next_payday + 1.month
    )
  end

  def is_active?
    status == 'active'
  end

end