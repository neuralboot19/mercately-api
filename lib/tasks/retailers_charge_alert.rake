namespace :retailers_charge_alert do
  task start: :environment do
    puts '*' * 70
    puts ' Checking Retailers for pending payments #RetailersChargeAlertJob '
    puts '*' * 70

    Retailers::RetailersChargeAlertJob.perform_at(Time.now)

    puts '*' * 35
    puts ' Finished #RetailersChargeAlertJob '
    puts '*' * 35
  end
end
