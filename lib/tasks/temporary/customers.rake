namespace :customers do
  task add_first_name_with_only_wa_name: :environment do
    Customer.where(first_name: [nil, '']).where.not(whatsapp_name: [nil, '']).find_each do |c|
      c.send :save_wa_name
      c.save
    end
  end
end
