namespace :customers do
  task update_invalid_customers: :environment do
    Customer.where(valid_customer: false).where.not(psid: nil).find_each do |c|
      url = prepare_person_url(c)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)

      if response['first_name'].present? || response['last_name'].present?
        c.update_columns(first_name: response['first_name'], last_name: response['last_name'], valid_customer: true)
      else
        c.update_column(:valid_customer, true)
      end
    end
  end
end

def prepare_person_url(customer)
  params = {
    fields: 'first_name,last_name,profile_pic',
    access_token: customer.retailer.facebook_retailer.access_token
  }

  "https://graph.facebook.com/#{customer.psid}?#{params.to_query}"
end
