module Whatsapp::Gupshup::V1::Helpers
  class Customers
    def self.save_customer(retailer, params)
      if params['direction'] == 'inbound'
        phone_to_find = "+#{params[:payload][:source]}"

        parse_phone = Phonelib.parse(phone_to_find)
        phone = params[:payload][:sender][:dial_code]
        country = parse_phone&.country

        if country == 'MX'
          phone_to_find[3] = '' if phone_to_find[3] == '1'
          phone[0] = '' if phone[0] == '1'
        end

        whatsapp_name = params['payload']['sender']['name']
      else
        phone_to_find = "+#{params[:payload][:destination]}"

        parse_phone = Phonelib.parse(phone_to_find)
        country = parse_phone&.country
        phone = phone_to_find.gsub("+#{country}", '')
      end

      customer = retailer.customers.find_by(phone: phone_to_find)

      customer.phone = phone if customer.present?
      customer = retailer.customers.find_or_initialize_by(phone: phone) unless customer
      customer.whatsapp_name = whatsapp_name if whatsapp_name

      customer.country_id = country

      customer.save!
      customer
    end
  end
end
