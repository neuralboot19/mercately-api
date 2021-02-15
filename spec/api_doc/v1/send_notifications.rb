module ApiDoc
  module V1
    module SendNotifications
      extend Dox::DSL::Syntax

      document :api do
        resource 'Notifications' do
          endpoint '/retailers/api/v1/whatsapp/send_notification_by_id'
          group 'Notifications'
          desc 'Documentation of notifications resources'
        end
      end

      # define data for specific action
      document :create_by_id do
        action 'Send a notification by ID'
      end
    end
  end
end
