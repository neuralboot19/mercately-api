namespace :payments do
  task set_main_card: :environment do
    Retailer.where(int_charges: true).find_each do |retailer|
      next unless retailer.payment_methods.exists?

      retailer.payment_methods.order(id: :desc).first&.update_column(:main, true)
    end

    Retailer.where(ecu_charges: true).find_each do |retailer|
      next unless retailer.paymentez_credit_cards.exists?

      retailer.paymentez_credit_cards.order(id: :desc).first&.update_column(:main, true)
    end
  end
end
