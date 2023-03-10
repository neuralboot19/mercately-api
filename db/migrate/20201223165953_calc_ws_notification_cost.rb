class CalcWsNotificationCost < ActiveRecord::Migration[5.2]
  def change
    Customer.where.not(country_id: [nil, '']).find_each do |customer|
      country_codes = JSON.parse(File.read("#{Rails.public_path}/json/all_countries_price.json"))
      price = country_codes[customer.country_id].presence || country_codes['Others']
      customer.update_column(:ws_notification_cost, price[0])
    end
  end
end
