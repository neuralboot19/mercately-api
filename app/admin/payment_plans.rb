ActiveAdmin.register PaymentPlan do
	permit_params :price, :start_date, :next_pay_date, :status, :plan
end