module Whatsapp::Gupshup::V1::Helpers
  class Customers
    def self.save_customer(retailer, params)
      if params['direction'] == 'inbound'
        phone_to_find = "+#{params[:payload][:source]}"

        parse_phone = Phonelib.parse(phone_to_find)
        phone = params[:payload][:sender][:dial_code]
        country = parse_phone&.country

        whatsapp_name = params['payload']['sender']['name']
      else
        phone_to_find = "+#{params[:payload][:destination]}"

        parse_phone = Phonelib.parse(phone_to_find)
        country = parse_phone&.country
        phone = phone_to_find.gsub("+#{country}", '')
      end

      customer = retailer.customers.find_by(phone: phone_to_find)
      original_phone = phone_to_find.dup

      if customer.blank? && country == 'MX' && phone_to_find[3] != '1'
        phone_to_find = phone_to_find.insert(3, '1')
        add_number = phone_to_find != original_phone
        customer = retailer.customers.find_by(phone: phone_to_find)
      end

      customer.phone = phone if customer.present?
      customer = retailer.customers.find_or_initialize_by(phone: phone) unless customer
      customer.whatsapp_name = whatsapp_name if whatsapp_name

      customer.country_id = country
      customer.number_to_use = original_phone if add_number

      customer.save!
      customer
    end
  end
end
