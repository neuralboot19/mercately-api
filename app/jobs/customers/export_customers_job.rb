module Customers
  class ExportCustomersJob < ApplicationJob
    queue_as :default

    def perform(retailer_id, retailer_email, params)
      retailer = Retailer.find(retailer_id)
      active_customers = retailer.customers.active
      active_customers.order(created_at: :desc) if params[:q] && params[:q]&.[](:s).blank?
      q = active_customers.ransack(params[:q])
      customers = q.result
      RetailerMailer.export_customers(retailer, retailer_email, Customer.to_csv(customers)).deliver_now
    end
  end
end
