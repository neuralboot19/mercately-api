module Retailers
  class MobilePushNotificationJob < ApplicationJob
    queue_as :mobile_push_notifications

    def perform(tokens, body)
      push_notification = PushNotification.new(tokens, body)
      push_notification.send_messages
    end
  end
end
