module Whatsapp
  module Karix
    class Customers
      def save_customer(retailer, phone)
        customer = retailer.customers.find_or_initialize_by(phone: phone)
        customer.save

        customer
      end
    end
  end
end
