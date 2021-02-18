module Retailers::Api::V1
  class RetailerUsersController < Retailers::Api::V1::ApiController
    def index
      agents = current_retailer.retailer_users

      render status: 200, json: {
        agents: serialize_agents(agents)
      }
    end

    private

      def serialize_agents(agents)
        ActiveModelSerializers::SerializableResource.new(
          agents,
          each_serializer: Retailers::Api::V1::AgentSerializer
        ).as_json
      end
  end
end
