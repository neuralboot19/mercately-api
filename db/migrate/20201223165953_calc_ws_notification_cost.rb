class CalcWsNotificationCost < ActiveRecord::Migration[5.2]
  def change
    Customer.where.not(country_id: [nil, '']).find_each do |customer|
      customer.update ws_notification_cost: customer.send(:calc_ws_notification_cost)
    end
  end
end
