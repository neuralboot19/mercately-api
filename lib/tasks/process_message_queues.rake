namespace :message_queues do
  task process_queues: :environment do
    CustomerQueue.where(:created_at.lt => 10.minutes.ago).order(created_at: :asc).each do |cq|
      customer = Customer.find_by(retailer_id: cq.retailer_id, phone: cq.source)

      if customer.present?
        cq.retry_customer_process(customer)
      else
        cq.retry_process
      end
    end
  end
end
