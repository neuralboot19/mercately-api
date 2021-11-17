module Retailers::Api::V1
  class AgentSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :admin, :retailer_id

    def admin
      object.retailer_admin
    end
  end
end
