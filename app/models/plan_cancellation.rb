class PlanCancellation < ApplicationRecord
  belongs_to :retailer

  enum reason: [:expensive, :not_help, :add_more_functionality, :never_used, :other, :unsupported_from_mercately]

  validates :reason, presence: true

  after_create :notify_slack

  private

    def notify_slack
      return unless ENV['ENVIRONMENT'] == 'production'

      plan = retailer.payment_plan
      data = [
        "PLAN CANCELADO",
        "Retailer: (#{retailer.id}) #{retailer.name}",
        "Plan: (#{plan.id}) #{plan.plan}",
        "Intervalo: #{plan.month_interval}",
        "Próxima fecha de cobro: #{plan.next_pay_date}",
        "Razón: #{PlanCancellation.enum_translation(:reason, reason)}",
        "Comentario: #{comment}"
      ]

      slack_client.ping(data.join("\n"))
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def slack_client
      Slack::Notifier.new ENV['SLACK_WEBHOOK']
    end
end
