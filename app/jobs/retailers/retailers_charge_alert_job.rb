module Retailers
  class RetailersChargeAlertJob
    include Sidekiq::Worker

    def perform
      PaymentPlan.eager_load(:retailer)
        .where(status: :active)
        .where.not(plan: :free)
        .where('next_pay_date <= NOW()')
        .each(&:notify_slack)
    end
  end
end
