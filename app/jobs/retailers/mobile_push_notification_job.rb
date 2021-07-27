module Retailers
  class MobilePushNotificationJob < ApplicationJob
    queue_as :mobile_push_notifications

    def perform(tokens, body, customer_id, channel = nil)
      push_notification = PushNotification.new(tokens, body, customer_id, channel)
      push_notification.send_messages
    end
  end
end
