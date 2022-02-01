namespace :customers do
  task update_conversation_cost: :environment do
    Customer.where.not(country_id: [nil, '']).find_each do |customer|
      country_codes = JSON.parse(File.read("#{Rails.public_path}/json/all_countries_price.json"))
      price = country_codes[customer.country_id].presence || country_codes['Others']
      customer.update_columns(ws_notification_cost: price[0], ws_bic_cost: price[1], ws_uic_cost: price[2])
    end
  end
end
