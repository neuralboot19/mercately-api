module Whatsapp
  module Karix
    class Customers
      def save_customer(retailer, ws_data)
        if ws_data['direction'] == 'inbound'
          phone = ws_data['source']
          source_profile = ws_data['channel_details']['whatsapp']['source_profile']
        else
          phone = ws_data['destination']
        end

        customer = retailer.customers.find_or_initialize_by(phone: phone)
        customer.whatsapp_name = source_profile['name'] if source_profile

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
