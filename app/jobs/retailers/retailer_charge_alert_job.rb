module Retailers
  class RetailerChargeAlertJob
    include Sidekiq::Worker

    def perform(payment_plan_id)
      return false unless payment_plan_id.present?

      payment_plan = PaymentPlan.eager_load(:retailer)
        .find(payment_plan_id)

      puts '*' * 150
      puts " Sending notification for pending payment to Retailer: #{payment_plan_id} "
      puts " Retailer Name: #{payment_plan.retailer.name} #RetailerChargeAlertJob_#{payment_plan_id} "
      puts '*' * 150

      payment_plan.notify_slack

      puts '*' * 80
      puts " Finished #RetailerChargeAlertJob_#{payment_plan_id} "
      puts '*' * 80
    rescue StandardError => e
      puts '*' * 80
      puts " Error sending charge notification #RetailerChargeAlertJob_#{payment_plan_id} "
      puts " Retailer ID: #{payment_plan_id} "
      puts " Error: #{e} "
      puts '*' * 80
      Raven.capture_exception "Error sending charge notification for Retailer id: #{payment_plan_id}"
    end
  end
end
