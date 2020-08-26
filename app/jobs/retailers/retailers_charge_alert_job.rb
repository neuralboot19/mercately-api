module Retailers
  class RetailersChargeAlertJob
    include Sidekiq::Worker

    def perform
      payment_plans = PaymentPlan.eager_load(:retailer)
        .where(status: :active)
        .where('next_pay_date <= NOW()')
        .where.not(plan: :free)

      no_pending_payments and return true unless payment_plans.any?

      payment_plans.each(&:notify_slack)
    end

    private

    def no_pending_payments
      slack_client.ping('No hay cuentas pendientes por cobrar')

      npd = (Date.today + 1.day).middle_of_day

      # We must convert the next pay date to a timestamp to shedule the job
      # since self.next_pay_date is type Date instead of type Time
      next_notification_at = Time.parse(npd.to_s).to_i

      # Schedule the next alert for tomorrow
      Retailers::RetailersChargeAlertJob.perform_at(
        next_notification_at,
      ) unless Rails.env == 'test'
    end

    def slack_client
      Slack::Notifier.new ENV['SLACK_WEBHOOK']
    end
  end
end
