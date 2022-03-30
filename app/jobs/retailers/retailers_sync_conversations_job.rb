module Retailers
  class RetailersSyncConversationsJob < ApplicationJob
    queue_as :low

    def perform
      Retailer.where(hs_next_sync: 2.hours.ago..Time.now, hs_sync_conversation: true)
      .where.not(hs_access_token: nil).find_each do |retailer|
        retailer.customers.where(hs_active: true).find_each do |customer|
          messages = []

          customer.tmp_messages.reverse.each do |message|
            messages << {
              "date": Time.parse(message["created_at"]).localtime.strftime("%d/%m/%Y, %I:%M%p"),
              "direction": message_direction(message),
              "message": message["message_payload"]
            }
          end

          next if messages.empty?

          title = customer.hs_event_title
          hs = HubspotService::Api.new(retailer.hs_access_token)
          response = hs.sync_conversations(customer.email, messages, title)

          next if response["status"].present? && response["status"] == "error"

          customer.update_messages

          customer.update!(tmp_messages: [])
          rescue StandardError => e
            Rails.logger.error e
            SlackError.send_error(e)
        end

        retailer.update(hs_next_sync: retailer.hs_next_sync + retailer.hs_conversacion_sync_time.hours)
      end
    end

    def message_direction(message)
      case message["direction"]
      when "inbound"
        "in"
      when "outbound"
        "out"
      else
        message["direction"]
      end
    end
  end
end