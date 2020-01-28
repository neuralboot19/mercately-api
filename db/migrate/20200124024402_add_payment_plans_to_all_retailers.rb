class AddPaymentPlansToAllRetailers < ActiveRecord::Migration[5.2]
  def change
  	Retailer.all.each do |r|
  		PaymentPlan.create(retailer: r)
  	end
  end
end
