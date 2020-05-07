module Whatsapp
  module Karix
    class Customers
      def save_customer(retailer, ws_data)
        phone = ws_data['direction'] == 'inbound' ? ws_data['source'] : ws_data['destination']
        customer = retailer.customers.find_or_initialize_by(phone: phone)

        if customer.country_id.blank?
          parse_phone = Phonelib.parse(phone)
          customer.country_id = parse_phone&.country
        end

        customer.save
        customer
      end
    end
  end
end
