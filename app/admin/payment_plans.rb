ActiveAdmin.register PaymentPlan do
  actions :all, except: :destroy
  permit_params :price, :start_date, :next_pay_date, :status, :plan, :karix_available_messages,
                :karix_available_notifications, :month_interval, :charge_attempt
end
