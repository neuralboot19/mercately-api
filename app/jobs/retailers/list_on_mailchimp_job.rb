module Retailers
  class ListOnMailchimpJob < ApplicationJob
    queue_as :default

    def perform(retailer_id)
      @retailer = Retailer.find(retailer_id)
      send_to_mailchimp
    end

    private

      def send_to_mailchimp
        gibbon = Gibbon::Request.new(api_key: ENV['MAILCHIMP_KEY'])
        gibbon.lists('71d07d1562').members.create(body:
          {email_address: @retailer.retailer_users.first.email, status: "subscribed", merge_fields:
          {RET_NAME: @retailer.name}})
      end
  end
end
