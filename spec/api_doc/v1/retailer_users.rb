module ApiDoc
  module V1
    module RetailerUsers
      extend Dox::DSL::Syntax

      document :api do
        resource 'Agents' do
          endpoint '/retailers/api/v1/agents'
          group 'Agents'
          desc 'Documentation of agents resources'
        end
      end

      # define data for specific action
      document :index do
        action 'Get agents'
      end
    end
  end
end
