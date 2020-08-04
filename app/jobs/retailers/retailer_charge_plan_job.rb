module Retailers
  class RetailerChargePlanJob
    include Sidekiq::Worker

    def perform(paymentez_cc_id)

      return false unless paymentez_cc_id.present?

      credit_card = PaymentezCreditCard.find(paymentez_cc_id)

      puts '*' * 150
      puts " Auto charging Plan ID: #{credit_card.retailer.plan} "
      puts " Retailer Name: #{credit_card.retailer.name} #RetailerChargePlanJob_#{paymentez_cc_id} "
      puts '*' * 150

      credit_card.create_transaction

      puts '*' * 80
      puts " Finished #RetailerChargePlanJob_#{paymentez_cc_id} "
      puts '*' * 80
    rescue StandardError => e
      puts '*' * 80
      puts " Error Auto charging plan #RetailerChargeAlertJob_#{paymentez_cc_id} "
      puts " Retailer ID: #{paymentez_cc_id} "
      puts " Error: #{e} "
      puts '*' * 80
      Raven.capture_exception "Error Auto charging plan for
                               Retailer id: #{credit_card.retailer_id}
                               Card Id: #{paymentez_cc_id}"
    end
  end
end
