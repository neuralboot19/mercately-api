namespace :facebook do
  task integrated: :environment do
    Customer.where.not(psid: [nil, '']).update_all(pstype: :messenger)
    FacebookRetailer.update_all(messenger_integrated: true)
  end
end
