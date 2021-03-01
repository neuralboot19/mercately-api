module ApiDoc
  module V1
    module WhatsappTemplates
      extend Dox::DSL::Syntax

      document :api do
        resource 'WhatsApp Templates' do
          endpoint '/retailers/api/v1/whatsapp_templates'
          group 'WhatsApp Templates'
          desc 'Documentation of whatsapp templates resources'
        end
      end

      # define data for specific action
      document :index do
        action 'Get WhatsApp templates'
      end
    end
  end
end
