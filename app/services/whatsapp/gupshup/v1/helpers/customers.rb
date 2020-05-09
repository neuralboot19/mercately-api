module Whatsapp::Gupshup::V1::Helpers
  class Customers
    def self.save_customer(retailer, params)
      if params['direction'] == 'inbound'
        phone_to_find = "+#{params[:payload][:source]}"

        parse_phone = Phonelib.parse(phone_to_find)
        phone = params[:payload][:sender][:dial_code]
        country = parse_phone&.country
      else
        phone_to_find = "+#{params[:payload][:destination]}"

        parse_phone = Phonelib.parse(phone_to_find)
        country = parse_phone&.country
        phone = phone_to_find.gsub("+#{country}", '')
      end

      customer = retailer.customers.find_by(phone: phone_to_find)

      customer.phone = phone if customer.present?
      customer = retailer.customers.find_or_initialize_by(phone: phone) unless customer

      customer.country_id = country
      customer.send_for_opt_in = true if customer.whatsapp_opt_in == false

      customer.save!
      customer
    end
  end
end
