module ApiDoc
  module V1
    module MessengerConversations
      extend Dox::DSL::Syntax

      document :api do
        resource 'Messenger Conversations' do
          endpoint '/retailers/api/v1/messenger_conversations'
          group 'Messenger Conversations'
          desc 'Documentation of Messenger conversations'
        end
      end

      # define data for specific action
      document :messenger_conversations do
        action 'Get Messenger conversations'
      end
    end
  end
end
