ActiveAdmin.register PaymentPlan do
  permit_params :price, :start_date, :next_pay_date, :status, :plan, :karix_available_messages,
                :karix_available_notifications
end
