module ApiDoc
  module V1
    module WhatsappConversations
      extend Dox::DSL::Syntax

      document :api do
        resource 'WhatsApp Conversations' do
          endpoint '/retailers/api/v1/whatsapp_conversations'
          group 'WhatsApp Conversations'
          desc 'Documentation of WhatsApp conversations'
        end
      end

      # define data for specific action
      document :whatsapp_conversations do
        action 'Get WhatsApp conversations'
      end
    end
  end
end
